from flask import Flask
from flask_socketio import SocketIO

import numpy as np
import mediapipe as mp

import time, os, json, cv2

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
    yuv = np.frombuffer(data['byte'], dtype=np.uint8).reshape(data['height'] * 3 // 2, data['width'])
    bgr = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420) # for cv2 output
    rgb = cv2.cvtColor(yuv, cv2.COLOR_YUV2RGB_I420) # for hand model input

@socketio.on('register_gesture')
def register_gesture(msg):
    data = json.loads(msg)
    is_last_chunk = data['isLastChunk']
    chunk_data = data['data']

    seq_length = 30

    if not hasattr(register_gesture, 'received_data'):
        register_gesture.received_data = bytearray()

    register_gesture.received_data.extend(chunk_data)

    if is_last_chunk:
        # All chunks have been received, reconstruct the original data
        reconstructed_data = bytes(register_gesture.received_data)

        # Initialize variables
        bytes_read = 0
        
        data = []
        # Loop over the reconstructed data to extract the images
        while bytes_read < len(reconstructed_data):
            # Extract the length of the next image
            length_bytes = reconstructed_data[bytes_read:bytes_read+4]
            length = int.from_bytes(length_bytes, byteorder='little')
            bytes_read += 4

            # Extract the next image data
            image_data = reconstructed_data[bytes_read:bytes_read+length]
            bytes_read += length

            # Decode the image using OpenCV
            nparr = np.frombuffer(image_data, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            result = hands.process(img)

            if result.multi_hand_landmarks is not None:
                for res in result.multi_hand_landmarks:
                    joint = np.zeros((21, 4))
                    for j, lm in enumerate(res.landmark):
                        joint[j] = [lm.x, lm.y, lm.z, lm.visibility]
                    
                    v1 = joint[[0, 1, 2, 3, 0, 5, 6, 7, 0, 9, 10, 11, 0, 13, 14, 15, 0, 17, 18, 19], :3]
                    v2 = joint[[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], :3]
                    v = v2 - v1

                    v = v / np.linalg.norm(v, axis=1)[:, np.newaxis]

                    angle = np.arccos(np.einsum('nt, nt->n',
                        v[[0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14, 16, 17, 18], :],
                        v[[1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19], :]
                    ))

                    angle = np.degrees(angle)

                    angle_label = np.array([angle], dtype=np.float32)
                    angle_label = np.append(angle_label, 1)

                    d = np.concatenate([joint.flatten(), angle_label])

                    data.append(d)

                    mp_drawing.draw_landmarks(img, res, mp_hands.HAND_CONNECTIONS)

            # # Display the image using OpenCV
            # cv2.imshow('Image', img)
            # cv2.waitKey(20)  # display each image for 20 milliseconds. about 50 fps.
        
        cv2.destroyAllWindows()
            
        data = np.array(data)
        # np.save(os.path.join('data', f'raw_{created_time}'), data)
        np.save(os.path.join('data', 'raw'), data)

        full_seq_data = []
        for seq in range(len(data) - seq_length):
            full_seq_data.append(data[seq:seq + seq_length])

        full_seq_data = np.array(full_seq_data)
        # np.save(os.path.join('data', f'seq_{created_time}'), full_seq_data)
        np.save(os.path.join('data', 'seq'), full_seq_data)

        # reset the received_data attribute for future use
        delattr(register_gesture, 'received_data')

@socketio.on('disconnect')
def disconnect():
    print('Disconnected.')

@socketio.on('connection')
def connection():
    print('Connected.')

if __name__ == '__main__':
    socketio.run(app, debug=True)