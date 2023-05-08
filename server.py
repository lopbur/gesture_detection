from flask import Flask
from flask_socketio import SocketIO
import numpy as np
import mediapipe, json, cv2, os, multiprocessing

from service import _gl, _dio, _wk, _pc 

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

    result = hands.process(image)

    if result.multi_hand_landmarks is None: return

    for hand_landmarks in result.multi_hand_landmarks:
        landmarks = np.zeros((21, 3))
        landmarks[:, 0] = np.array([lm.x for lm in hand_landmarks.landmark])
        landmarks[:, 1] = np.array([lm.y for lm in hand_landmarks.landmark])
        landmarks[:, 2] = np.array([lm.z for lm in hand_landmarks.landmark])
        v = landmarks[[0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14, 16, 17, 18], :]
        - landmarks[[1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19], :]
        v = v / np.linalg.norm(v, axis=1, keepdims=True) + 1e-8
        angle = np.degrees(np.arctan2(np.linalg.norm(np.cross(v[:-1], v[1:]), axis=1), np.einsum('ij,ij->i', v[:-1], v[1:])))
        
        miq.put((landmarks,None))
        giq.put((landmarks, angle))

    try:
        print(moq.get_nowait())
    except:
        pass

    if landmarks is not None and angle is not None:
        socketio.emit('response_landmark', json.dumps(landmarks.tolist()))
    else:
        socketio.emit('response_landmark', json.dumps([ ]))



@socketio.on('disconnect')
def disconnect():
    socketio.emit('disconnect')
    print('Disconnected.')

@socketio.on('connection')
def connection():
    print('Connected.')

if __name__ == '__main__':
    CONFIG_PATH = os.path.abspath(_gl.CONFIG_PATH)
    GESTURE_LABEL_PATH = os.path.abspath(os.path.join(_gl.OLD_DATA_FOLDER_NAME, _gl.LABEL_NAME))

    config = _dio.load_config(CONFIG_PATH, _gl.CONFIG_PRESET)

    # Mediapipe Hands 모델 초기화
    mp_drawing = mediapipe.solutions.drawing_utils
    mp_hands = mediapipe.solutions.hands
    hands = mp_hands.Hands(
        max_num_hands=1,  # 추출할 손의 최대 개수
        min_detection_confidence=0.5,  # 손 인식 확률의 최소 기준값
        min_tracking_confidence=0.5)  # 손 추적 확률의 최소 기준값
    
    miq, moq = multiprocessing.Queue(), multiprocessing.Queue()
    giq = multiprocessing.Queue()
    m_args = {
        'gesture_event_list': config[_gl.GESTURE_EVENT_SECTION],
    }
    motion_process = multiprocessing.Process(target=_wk.motion_worker, args=(miq, moq, m_args))
    motion_process.daemon = True

    gesture_process = multiprocessing.Process(target=_wk.gesture_worker, args=(giq, miq, []))
    gesture_process.daemon = True

    
    try:
        motion_process.start()
        gesture_process.start()
        socketio.run(app, debug=True,)
    except KeyboardInterrupt:
        print('Keyboard Interrupt detected.')
        exit()