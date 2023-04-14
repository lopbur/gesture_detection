import numpy as np
import mediapipe as mp
import time, os, cv2, sys

import service.globals as _g
import service.data_io as _dio
import service.parser as _psr


cap = cv2.VideoCapture(0)

args = _psr.parse_arguments()

# initialize with arguments
cur_path = _g.NEW_DATA_FOLDER_NAME if args.n else _g.OLD_DATA_FOLDER_NAME
old_data_path = os.path.abspath(_g.OLD_DATA_FOLDER_NAME)
new_data_path = os.path.abspath(_g.NEW_DATA_FOLDER_NAME)
save_path = os.path.abspath(cur_path)
action_time = args.c

# initialize folder
_dio.create_data_init(old_data_path, new_data_path)

mp_hands = mp.solutions.hands
mp_draws = mp.solutions.drawing_utils
landmark_model = mp_hands.Hands(
    max_num_hands=1,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5)

while cap.isOpened():
    label = input('enter the label of action: ')
    if label == '':
        break

    ret, img = cap.read()

    img = cv2.flip(img, 1)

    # Preparation time before data collection
    cv2.putText(img, f'Waiting for collectig {label.upper()} action..', org=(10,  30),
    fontFace=cv2.FONT_HERSHEY_SIMPLEX, fontScale=1, color=(255, 255, 255), thickness=2)

    cv2.imshow('img', img)  
    cv2.waitKey(1500)

    start_time = time.time()
    data = []

    # Collect data for a specified period of time
    while time.time() - start_time < action_time:
        ret, img = cap.read()

        img = cv2.flip(img, 1)
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        result = landmark_model.process(img)

        img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

        if result.multi_hand_landmarks is not None:
            for res in result.multi_hand_landmarks:
                joint = _psr.get_joint_from_landmarks(res)
                angle = _psr.get_angle_from_joint(joint)

                data.append(angle)

                mp_draws.draw_landmarks(img, res, mp_hands.HAND_CONNECTIONS)
        
        cv2.imshow('img', img)
        if cv2.waitKey(1) == ord('q'):
            print('Data collecting early stopped.')
            break

    # save label
    isNotExist, label_num = _dio.get_label_num(label, os.path.abspath('.'))
    if isNotExist:
        with open(os.path.join(cur_path, 'labels.txt'), 'a') as f:
            f.write(f'{label} {label_num}\n')

    # save data
    _dio.save_gesture(
        data,
        save_path,
        label,
        overwrite=args.r)