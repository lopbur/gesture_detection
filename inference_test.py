from keras.models import load_model

import numpy as np
import service.train as train_service

import cv2, os

seq_length = 30

# define base data, label store path
old_data_path = os.path.abspath(train_service.OLD_DATA_PATH)
new_data_path = os.path.abspath(train_service.NEW_DATA_PATH)

load_model_path = f'{train_service.MODEL_PATH}/base_model.h5'
label_file_name = 'labels.txt'

old_actions, old_labels = train_service.load_gesture_label(os.path.join(old_data_path, label_file_name))
new_actions, new_labels = train_service.load_gesture_label(os.path.join(new_data_path, label_file_name))

actions = np.concatenate([old_actions, new_actions])
print(f'Current trained actions: {actions}')

model = load_model(load_model_path)

cap = cv2.VideoCapture(0)

seq = []
action_seq = []

while cap.isOpened():
    ret, img = cap.read()
    img0 = img.copy()

    img = cv2.flip(img, 1)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    result = train_service.HANDS_INST.process(img)
    img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

    if result.multi_hand_landmarks is not None:
        for res in result.multi_hand_landmarks:
            joint = train_service.get_joint_from_landmarks(res)
            angle = train_service.get_angle_from_joint(joint)
            
            seq.append(angle)
                
            train_service.MP_DRAW.draw_landmarks(img, res, train_service.mp_hands.HAND_CONNECTIONS)

            if len(seq) < seq_length:
                continue

            input_data = np.expand_dims(np.array(seq[-seq_length:], dtype=np.float32), axis=0)

            y_pred = model.predict(input_data, verbose=None).squeeze()

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