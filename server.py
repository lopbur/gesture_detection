from flask import Flask
from flask_socketio import SocketIO

import mediapipe as mp
import numpy as np

import json, cv2, os
from service import _pc, _wk, _mg, _gl, _dio

app = Flask(__name__)
app.config['SECRET_KEY'] = 'm1y2S3e4C5r6E7t8'

socketio = SocketIO(app)

@socketio.on('hand_stream')
def handle_hand_stream(msg):
    data = json.loads(msg)

    # Get require data from dictionary 
    byte = data.get('byte')
    width = data.get('width')
    height = data.get('height')
    
    image_np = np.array(byte, dtype=np.uint8).reshape(height, width)
    image = cv2.cvtColor(image_np, cv2.COLOR_GRAY2RGB)

    joint, angle = lm.inference(image)
    if joint is not None and angle is not None:
        gesture_input = np.concatenate([joint.flatten(), angle], axis=0)

        pm.processes.get('window').args[0][0].put({'landmark': joint[0]})
        pm.processes.get('gesture').args[0][0].put(gesture_input)

        socketio.emit('response_landmark', json.dumps(joint.tolist()))
    else:
        socketio.emit('response_landmark', json.dumps([]))


@socketio.on('update_event_list')
def handle_update_event_list(msg):
    data = json.loads(msg)
    print(f'update_event_list handler received: {data}')
    # need implement

@socketio.on('register_gesture')
def handle_register_gesture(msg):
    data = json.loads(msg) # get chunked data
    print(f'register_gesture: received data: {data}')
    # need implement

@socketio.on('disconnect')
def disconnect():
    socketio.emit('disconnect')
    print('Disconnected.')

@socketio.on('connection')
def connection():
    print('Connected.')

if __name__ == '__main__':
    try:
        CONFIG_PATH = os.path.abspath(_gl.CONFIG_PATH)
        GESTURE_LABEL_PATH = os.path.abspath(os.path.join(_gl.OLD_DATA_FOLDER_NAME, _gl.LABEL_NAME))
        
        # ['clenching', 'foldindex', 'foldindexmiddle', 'touchindex', 'touchmiddle']
        gesture_name, gesture_label = _dio.load_gesture_label(GESTURE_LABEL_PATH)
        config = _dio.load_config(CONFIG_PATH, _gl.CONFIG_PRESET)
        gesture_event = config[_gl.GESTURE_EVENT_SECTION]
        pm = _pc.ProcessManager()
        lm = _mg.LandmarkManager(mp_hands=mp.solutions.hands,
                                mp_draws=mp.solutions.drawing_utils)
        
        
        pm.add_process(alias='gesture', worker=_wk.gesture_inference_worker, args=(gesture_name,))
        pm.add_process(alias='window', worker=_wk.window_worker, args=(gesture_event,))

         # for pass gesture inference result to window worker control
        pm.link(source="gesture", destination="window")

        # Input for landmark data,
        # Output for result of gesture inference
        pm.add_io(alias='gesture', io='i')

        pm.start_all_process()

        gesture_process = pm.processes.get('gesture')
        window_process = pm.processes.get('window')
        
        # Run on only python with opencv2
        if _gl.DEVELOP_MODE:
            cap = cv2.VideoCapture(0)
            while(True):
                ret, frame = cap.read()
        else:
            socketio.run(app, debug=True,)
    except KeyboardInterrupt:
        pm.stop_all_process(None)
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