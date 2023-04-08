from flask import Flask
from flask_socketio import SocketIO

import numpy as np
import mediapipe as mp
import os, json, cv2

from service import train, model, req_gesture

app = Flask(__name__)
app.config['SECRET_KEY'] = 'm1y2S3e4C5r6E7t8'

socketio = SocketIO(app)

mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils

hands = mp_hands.Hands(
    max_num_hands = 2,
    min_detection_confidence = 0.5,
    min_tracking_confidence = 0.5,
)

@socketio.on('hand_stream')
def hand_stream(msg):
    data = json.loads(msg)
    # convert byte stream to yuv420 format
    yuv = np.array(data['byte'], dtype=np.uint8).reshape(data['height'] * 3 // 2, data['width'])
    bgr = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420) # for cv2 output
    rgb = cv2.cvtColor(yuv, cv2.COLOR_YUV2RGB_I420) # for hand model input

    result = model.hands.process(rgb)

    if result.multi_hand_landmarks is not None:
        for res in result.multi_hand_landmarks:
            model.mp_drawing.draw_landmarks(bgr, res, mp_hands.HAND_CONNECTIONS)

    cv2.imshow('img', bgr)
    cv2.waitKey(1)


@socketio.on('register_gesture')
def register_gesture(msg):
    data = json.loads(msg)
    is_last_chunk = data['chunk']['isLastChunk']
    chunk_data = data['chunk']['data']

    if 'meta' in data:
        if not hasattr(register_gesture, 'received_meta'):
            register_gesture.received_meta = data['meta']

    if not hasattr(register_gesture, 'received_chunk'):
        register_gesture.received_chunk = bytearray()

    register_gesture.received_chunk.extend(chunk_data)

    if is_last_chunk:
        label = register_gesture.received_meta['label']
        label_num = -1

        with open(train.base_label_path, 'r') as f:
            lines = f.readlines()

        for i, line in enumerate(lines):
            if label in line:
                label_num = i

        if label_num == -1:
            with open(train.base_label_path, 'a') as f:
                f.write(f'{label} {len(lines)}\n')
                label_num = len(lines)
        
        imgs = req_gesture.byteToCV2List(bytes(register_gesture.received_chunk))
        data = model.getHandAngleWithCV2List(imgs, label_num)

        seq_length = 30

        full_seq_data = []
        for seq in range(len(data) - seq_length):
            full_seq_data.append(data[seq:seq + seq_length])
        
        # save train set as raw data
        data = np.array(data)
        np.save(os.path.join('data', f'raw_{label}'), data)

        # save train set as sequence data
        full_seq_data = np.array(full_seq_data)
        np.save(os.path.join('data', f'seq_{label}'), full_seq_data)

        # reset the received_data attribute for future use
        delattr(register_gesture, 'received_chunk')
        delattr(register_gesture, 'received_meta')

        for img in imgs:
            cv2.imshow('gesture', img)
            cv2.waitKey(20)
            
        cv2.destroyAllWindows()

@socketio.on('disconnect')
def disconnect():
    print('Disconnected.')

@socketio.on('connection')
def connection():
    print('Connected.')

if __name__ == '__main__':
    socketio.run(app, debug=True)