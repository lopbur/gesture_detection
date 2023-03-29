from pprint import pprint
from flask import Flask
from flask_socketio import SocketIO

import json
import lib.service.convert as Convert
import lib.service.gesture as Gesture
import lib.service.hand as Hand
import lib.service.addTrain as Train
import numpy as np
import cv2

import mediapipe as mp

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

@socketio.on('disconnect')
def disconnect():
    print('disconnected')

@socketio.on('connection')
def connection(data):
    socketio.emit('hello', 'world')

@socketio.on('hand_stream')
def hand_stream(msg):
    data = json.loads(msg)

    # convert byte stream to yuv420 format
    yuv = Convert.convertBytelistToImage(data['byte'], data['height'], data['width'], 'yuv')
    bgr = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420) # for cv2 output
    rgb = cv2.cvtColor(yuv, cv2.COLOR_YUV2RGB_I420) # for hand model input
    

@socketio.on('register_gesture')
def register_gesture(msg):
    data = json.loads(msg)
    is_last_chunk = data['isLastChunk']
    chunk_data = data['data']

    
    if not hasattr(register_gesture, 'received_data'):
        register_gesture.received_data = bytearray()

    register_gesture.received_data.extend(chunk_data)

    if is_last_chunk:
        # All chunks have been received, reconstruct the original data
        reconstructed_data = bytes(register_gesture.received_data)

        # Initialize variables
        bytes_read = 0

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

            # Display the image using OpenCV
            cv2.imshow('Image', img)
            cv2.waitKey(20)  # display each image for 10 milliseconds

        cv2.destroyAllWindows()

        # reset the received_data attribute for future use
        delattr(register_gesture, 'received_data')


@socketio.on('request_landmark')
def request_landmark(msg):
    data = json.loads(msg)
    print(data)

@socketio.on('request_gesture')
def request_gesture(msg):
    data = json.loads(msg)
    print(msg['isLastChunk'])

if __name__ == '__main__':
    socketio.run(app, debug=True)

    