import cv2
import numpy as np
import time

import mediapipe as mp
import multiprocessing as mulp
import service.globals as _g    # global variables

class InferenceManager:
    def __init__(self,
                landmark_model,
                gesture_model,
                detection_threshold,
                sequence_length=30,
                max_sequence_limit=100):
        self.landmark_model = landmark_model
        self.gesture_model = gesture_model
        self.detection_threshold = detection_threshold
        self.sequence_length = sequence_length
        self.max_sequence_limit = max_sequence_limit
        self.gesture_buffer_arr = []
        self.gesture_buffer = np.zeros((30, 77), dtype=np.float32)
        self.recent_inference_sequence = np.empty((0, ), dtype=int)

        self.mp_draws = mp.solutions.drawing_utils
        self.mp_hands = mp.solutions.hands

    def landmark_inference(self, image):
        result = self.landmark_model.process(image)
        gesture_sequences = np.empty((30, 77), dtype=np.float32)
        limit_sequence_length = 100
        sequence_length = 30

        if result.multi_hand_landmarks is not None:
            for res in result.multi_hand_landmarks:
                joint = self.get_joint_from_landmarks(res.landmark)
                angle = self.get_angle_from_joint(joint)
                self.mp_draws.draw_landmarks(image, res, self.mp_hands.HAND_CONNECTIONS)

                gesture_sequences = np.append(gesture_sequences, angle[np.newaxis, :], axis=0)
                buflen = len(gesture_sequences)
                if buflen < 30: continue
                elif buflen > limit_sequence_length:
                    gesture_sequences = gesture_sequences[-sequence_length:]
                y_pred = self.gesture_model.predict(gesture_sequences[np.newaxis, :], verbose=None).squeeze()
                     
                input_data = np.expand_dims(np.array(gesture_sequences[-sequence_length:], dtype=np.float32), axis=0)

                # self.gesture_buffer = np.concatenate((self.gesture_buffer, angle[np.newaxis, :]), axis=0)
                # y_pred = self.gesture_model.predict(np.array(self.gesture_buffer)[np.newaxis, -30 :], verbose=None).squeeze()

                # self.gesture_buffer[:-1] = self.gesture_buffer[1:]
                # self.gesture_buffer[-1] = angle
                # y_pred = self.gesture_model.predict(self.gesture_buffer[np.newaxis, :, :], verbose=None).squeeze()
                # print(f'{y_pred} inference complete -> {time.time()}\n')
            cv2.imshow('image', image)
            cv2.waitKey(1)


    def get_joint_from_landmarks(self, landmarks):
        return np.array([[landmark.x, landmark.y, landmark.z] for landmark in landmarks], dtype=np.float32)
            
    def get_angle_from_joint(self, joint):
            v = joint[[0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14, 16, 17, 18], :]
            - joint[[1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19], :]
            v = v / np.linalg.norm(v, axis=1, keepdims=True) + 1e-8

            angle = np.degrees(np.arctan2(np.linalg.norm(np.cross(v[:-1], v[1:]), axis=1), np.einsum('ij,ij->i', v[:-1], v[1:])))

            return np.concatenate([joint.flatten(), angle], axis=0)