from keras.models import load_model

import numpy as np
import service.globals as _g
import service.data_io as _dio
import service.parser as _psr
import mediapipe as mp

import cv2, os

seq_length = 30

# define base data, label store path
old_data_path = os.path.abspath(_g.OLD_DATA_FOLDER_NAME)
new_data_path = os.path.abspath(_g.NEW_DATA_FOLDER_NAME)
old_label_path = os.path.join(old_data_path, _g.LABEL_NAME)
new_label_path = os.path.join(new_data_path, _g.LABEL_NAME)

load_model_path = f'{_g.MODEL_FOLDER_NAME}/base_model1.h5'

actions, labels = _dio.load_gesture_label(old_label_path)

print(f'Current trained actions: {actions}')

mp_hands = mp.solutions.hands
mp_draws = mp.solutions.drawing_utils
landmark_model = mp_hands.Hands(
    max_num_hands=1,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5)
GESTURE_MODEL_PATH = os.path.abspath(os.path.join(_g.MODEL_FOLDER_NAME, _g.GESTURE_MODEL_NAME))
gesture_model = load_model(GESTURE_MODEL_PATH)

cap = cv2.VideoCapture(0)

seq = []
action_seq = []

while cap.isOpened():
    ret, img = cap.read()
    img0 = img.copy()

    img = cv2.flip(img, 1)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    result = landmark_model.process(img)
    img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

    if result.multi_hand_landmarks is not None:
        for res in result.multi_hand_landmarks:
            joint = _psr.get_joint_from_landmarks(res)
            angle = _psr.get_angle_from_joint(joint)
            
            seq.append(angle)
                
            mp_draws.draw_landmarks(img, res, mp_hands.HAND_CONNECTIONS)

            if len(seq) < seq_length:
                continue

            input_data = np.expand_dims(np.array(seq[-seq_length:], dtype=np.float32), axis=0)

            y_pred = gesture_model.predict(input_data, verbose=None).squeeze()

            i_pred = int(np.argmax(y_pred))
            conf = y_pred[i_pred]
            print(y_pred)

            if conf < 0.7:
                continue

            action = actions[i_pred]
            action_seq.append(action)

            this_action = '?'

            if len(action_seq) < 3:
                continue
            
            if action_seq[-1] == action_seq[-2] == action_seq[-3]:
                this_action = action


            cv2.putText(img, f'{this_action.upper()}',
                        org=(int(res.landmark[0].x * img.shape[1]+ 50),
                             int(res.landmark[0].y * img.shape[0] + 50)),
                             fontFace=cv2.FONT_HERSHEY_SIMPLEX,
                             fontScale=1,
                             color=(255, 255, 255),
                             thickness=2)

    # out.write(img0)
    # out2.write(img)
    cv2.imshow('img', img)
    if cv2.waitKey(1) == ord('q'):
        break