from typing import Dict
from flask import Flask
from flask_socketio import SocketIO

import os, json

import service.handler as server_handler
import service.parser as server_parser

app = Flask(__name__)
app.config['SECRET_KEY'] = 'm1y2S3e4C5r6E7t8'

socketio = SocketIO(app)

@socketio.on('hand_stream')
def handle_hand_stream(msg):
    data: Dict = json.loads(msg)

    # Get require data from dictionary 
    byte = data.get('byte')
    height = data.get('height')
    width = data.get('width')

    # Validate data
    if byte is None or height is None or width is None:
        print('Missing require data founded. hand stream not processed.')
    else:
        result = server_handler.hand_stream(msg)
    
    print(result)


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
        
#         imgs = server_parser.byteToCV2List(bytes(register_gesture.received_chunk))
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

@socketio.on('disconnect')
def disconnect():
    print('Disconnected.')

@socketio.on('connection')
def connection():
    print('Connected.')

if __name__ == '__main__':
    socketio.run(app, debug=True)