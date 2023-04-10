
from keras.models import load_model
import numpy as np
import os, cv2

import service.train as train_service

GESTURE_SEQUENCES = []
ACTION_SEQUENCES = np.array([])

# Judges to have inferred correctly, 
# if same gesture inference result {ACTION_THRESHOLD} times in a row,
ACTION_THRESHOLD = 3
GESTURE_INFERENCE_THRESHOLD = 0.8

MODEL_NAME = 'base_model.h5'
MODEL_PATH = os.path.abspath(os.path.join(train_service.MODEL_PATH, MODEL_NAME))
GESTURE_MODEL = load_model(MODEL_PATH)


# define data and label store path
OLD_DATA_PATH = os.path.abspath(train_service.OLD_DATA_PATH)
NEW_DATA_PATH = os.path.abspath(train_service.NEW_DATA_PATH)
OLD_LABEL_PATH = os.path.join(OLD_DATA_PATH, train_service.LABEL_NAME)
NEW_LABEL_PATH = os.path.join(NEW_DATA_PATH, train_service.LABEL_NAME)

old_actions, old_labels = train_service.load_gesture_label(OLD_LABEL_PATH)
new_actions, new_labels = train_service.load_gesture_label(NEW_LABEL_PATH)

    
def proc_hand_stream(image_bytes, image_width, image_height):
    # convert byte stream to yuv420 format
    yuv = np.array(image_bytes, dtype=np.uint8).reshape(image_height * 3 // 2, image_width)
    bgr = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420) # for cv2 output
    rgb = cv2.cvtColor(yuv, cv2.COLOR_YUV2RGB_I420) # for hand model input

    landmark_result = train_service.HANDS_INST.process(rgb)

    if landmark_result.multi_hand_landmarks is not None:
        for res in landmark_result.multi_hand_landmarks:
            joint = train_service.get_joint_from_landmarks(res)
            angle = train_service.get_angle_from_joint(joint)
            train_service.MP_DRAW.draw_landmarks(bgr, res, train_service.MP_HANDS.HAND_CONNECTIONS)

            GESTURE_SEQUENCES.append(angle)
            if len(GESTURE_SEQUENCES) < train_service.SEQ_LENGTH:
                continue
            elif len(GESTURE_SEQUENCES) > train_service.MAX_SAVE_SEQ_LENGTH:
                GESTURE_SEQUENCES = GESTURE_SEQUENCES[-train_service.SEQ_LENGTH:]

            input = np.expand_dims(np.array(GESTURE_SEQUENCES[-train_service.SEQ_LENGTH:], dtype=np.float32), axis=0).copy()
            predict_y = np.array(GESTURE_MODEL.predict(input, verbose=0).squeeze())
            predict_index = np.max(predict_y)
            
            conf = float(predict_index)
            if conf < GESTURE_INFERENCE_THRESHOLD:
                continue

            # ACTION_SEQUENCES.append(predict_index)
            ACTION_SEQUENCES = np.append(ACTION_SEQUENCES, predict_index)
            if len(ACTION_SEQUENCES) < 3:
                continue
            else:
                is_recent_same = np.all(ACTION_SEQUENCES[-ACTION_THRESHOLD:] == ACTION_SEQUENCES[-1])

            if is_recent_same:
                inference_gesture_result = ACTION_NAMES[predict_index]


    
    return landmark_result, inference_gesture_result

    # Testing application connection establishment.
    # cv2.imshow('img', bgr)
    # if cv2.waitKey(1) == ord('q'):
    #     cv2.destroyAllWindows()
