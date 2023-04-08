import numpy as np
import service.train as train_service

import time, os, cv2, sys

cap = cv2.VideoCapture(0)

args = train_service.parse_arguments()

# initialize with arguments
cur_path = train_service.new_data_path if args.n else train_service.old_data_path
save_path = os.path.abspath(cur_path)
action_time = args.c

# initialize folder
train_service.init(os.path.abspath('.'))
    
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

        result = train_service.hands.process(img)

        img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

        if result.multi_hand_landmarks is not None:
            for res in result.multi_hand_landmarks:
                joint = train_service.get_joint_from_landmarks(res)
                angle = train_service.get_angle_from_joint(joint)

                data.append(angle)

                train_service.mp_drawing.draw_landmarks(img, res, train_service.mp_hands.HAND_CONNECTIONS)
        
        cv2.imshow('img', img)
        if cv2.waitKey(1) == ord('q'):
            print('Data collecting early stopped.')
            break

    # save label
    isNotExist, label_num = train_service.get_label_num(label, os.path.abspath('.'))
    if isNotExist:
        with open(os.path.join(cur_path, 'labels.txt'), 'a') as f:
            f.write(f'{label} {label_num}\n')

    # save data
    train_service.save_gesture(
        data,
        save_path,
        label,
        overwrite=args.r)