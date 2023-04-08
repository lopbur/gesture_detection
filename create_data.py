import numpy as np
import service.tdata as ts
import service.cdata as ds

import time, os, cv2, sys

cap = cv2.VideoCapture(0)

args = ds.parse_arguments()

# initialize with arguments
cur_path = ds.new_data_path if args.n else ds.old_data_path
save_path = os.path.abspath(cur_path)
action_time = args.c

# initialize folder
ds.init(os.path.abspath('.'))
    
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

        result = ts.hands.process(img)

        img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

        if result.multi_hand_landmarks is not None:
            for res in result.multi_hand_landmarks:
                joint = np.zeros((21, 3))
                for j, lm in enumerate(res.landmark):
                    joint[j] = [lm.x, lm.y, lm.z]

                data.append(ts.getAngle(joint))

                ts.mp_drawing.draw_landmarks(img, res, ts.mp_hands.HAND_CONNECTIONS)
        
        cv2.imshow('img', img)
        if cv2.waitKey(1) == ord('q'):
            print('Data collecting early stopped.')
            break

    # save label
    isNotExist, label_num = ds.get_label_num(label, os.path.abspath('.'))
    if isNotExist:
        with open(os.path.join(cur_path, 'labels.txt'), 'a') as f:
            f.write(f'{label} {label_num}\n')

    # save data
    ds.save_gesture(
        data,
        save_path,
        label,
        overwrite=args.r)