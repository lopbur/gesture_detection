from flask import Flask
from flask_socketio import SocketIO
from typing import Dict

from keras.models import load_model
import mediapipe as mp

import multiprocessing as mulp
import numpy as np
import json, cv2, os, time

import py_gesture as _pgclwkr
import service.parser as _psr
import service.globals as _g

os.environ['CUDA_VISIBLE_DEVICES'] = '0'
os.environ['TF_FORCE_GPU_ALLOW_GROWTH'] = 'true'

app = Flask(__name__)
app.config['SECRET_KEY'] = 'm1y2S3e4C5r6E7t8'

socketio = SocketIO(app)

mp_hands = mp.solutions.hands
mp_draws = mp.solutions.drawing_utils
landmark_model = mp_hands.Hands(
    max_num_hands=1,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5)
GESTURE_MODEL_PATH = os.path.abspath(os.path.join(_g.MODEL_FOLDER_NAME, _g.GESTURE_MODEL_NAME))
gesture_model = load_model(GESTURE_MODEL_PATH)

inf_manager = _pgclwkr.inf.InferenceManager(landmark_model=landmark_model,
                                            gesture_model=gesture_model,
                                            detection_threshold=0.5)

inference_input_q = inference_output_q = mulp.Queue()

def gesture_inference_worker(input_q, output_q):
    buffer = []
    while True:
        input = input_q.get()
        print(input)
        if input is None: break
        buffer.append(input)
        if len(buffer) < 30: continue
        input_data = np.expand_dims(np.array(buffer[-30:], dtype=np.float32), axis=0)
        y_pred = gesture_model.predict(input_data, verbose=None).squeeze()
        print(f'{y_pred} inference complete at {time.time()}\n')

        # output_q.put(int(np.argmax(y_pred)))

@socketio.on('hand_stream')
def handle_hand_stream(msg):
    global buffer
    data: Dict = json.loads(msg)

    # Get require data from dictionary 
    byte = data.get('byte')
    width = data.get('width')
    height = data.get('height')
    
    image_np = np.array(byte, dtype=np.uint8).reshape(height, width)
    image = cv2.cvtColor(image_np, cv2.COLOR_GRAY2RGB)
    # inf_manager.landmark_inference(image)
    
    result = landmark_model.process(image)
    if result.multi_hand_landmarks is not None:
        for res in result.multi_hand_landmarks:
            joint = np.zeros((21, 3))
            joint[:, 0] = np.array([lm.x for lm in res.landmark])
            joint[:, 1] = np.array([lm.y for lm in res.landmark])
            joint[:, 2] = np.array([lm.z for lm in res.landmark])
            v = joint[[0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14, 16, 17, 18], :]
            - joint[[1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19], :]
            v = v / np.linalg.norm(v, axis=1, keepdims=True) + 1e-8
            angle = np.degrees(np.arctan2(np.linalg.norm(np.cross(v[:-1], v[1:]), axis=1), np.einsum('ij,ij->i', v[:-1], v[1:])))
            angle = np.concatenate([joint.flatten(), angle], axis=0)
            mp_draws.draw_landmarks(image, res, mp_hands.HAND_CONNECTIONS)

            input_q.put(angle)
            
    cv2.imshow('image', image)
    cv2.waitKey(1)

@socketio.on('disconnect')
def disconnect():
    print('Disconnected.')

@socketio.on('connection')
def connection():
    print('Connected.')

if __name__ == '__main__':
    try:
        gesture_processer = mulp.Process(target=gesture_inference_worker, args=(inference_input_q, inference_output_q))
        gesture_processer.daemon = True
        gesture_processer.start()
        socketio.run(app, debug=True,)
        print('server started.')
    except KeyboardInterrupt:
        inference_input_q.put(None)
        gesture_processer.join()
        gesture_processer = None
        exit()

# @socketio.on('register_gesture')
# def register_gesture(msg):
#     data = json.loads(msg)
#     is_last_chunk = data['chunk']['isLastChunk']
#     chunk_data = data['chunk']['data']

#     if 'meta' in data:
#         if not hasattr(register_gesture, 'received_meta'):
#             register_gesture.received_meta = data['meta']

#     if not hasattr(register_gesture, 'received_chunk'):
#         register_gesture.received_chunk = bytearray()

#     register_gesture.received_chunk.extend(chunk_data)

#     if is_last_chunk:
#         label = register_gesture.received_meta['label']
#         label_num = -1

#         with open(train_service.base_label_path, 'r') as f:
#             lines = f.readlines()

#         for i, line in enumerate(lines):
#             if label in line:
#                 label_num = i

#         if label_num == -1:
#             with open(train_service.base_label_path, 'a') as f:
#                 f.write(f'{label} {len(lines)}\n')
#                 label_num = len(lines)
        
#         imgs = server_psr.byteToCV2List(bytes(register_gesture.received_chunk))
#         data = train_service.model.getHandAngleWithCV2List(imgs, label_num)

#         seq_length = 30

#         full_seq_data = []
#         for seq in range(len(data) - seq_length):
#             full_seq_data.append(data[seq:seq + seq_length])
        
#         # save train set as raw data
#         data = np.array(data)
#         np.save(os.path.join('data', f'raw_{label}'), data)

#         # save train set as sequence data
#         full_seq_data = np.array(full_seq_data)
#         np.save(os.path.join('data', f'seq_{label}'), full_seq_data)

#         # reset the received_data attribute for future use
#         delattr(register_gesture, 'received_chunk')
#         delattr(register_gesture, 'received_meta')

#         for img in imgs:
#             cv2.imshow('gesture', img)
#             cv2.waitKey(20)
            
#         cv2.destroyAllWindows()