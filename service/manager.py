import numpy as np
import pyautogui as gui

from keras.models import load_model

class LandmarkManager:
    def __init__(self,
                 mp_hands,
                 mp_draws):
        self.mp_hands = mp_hands
        self.mp_draws = mp_draws
        self.landmark = self.mp_hands.Hands(
            max_num_hands=1,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5)

    def inference(self, image):
        result = self.landmark.process(image)
        joint = angle = None

        if result.multi_hand_landmarks is not None:
            for res in result.multi_hand_landmarks:
                joint, angle = self.get_joint_from_landmarks_and_angle(res.landmark)
                self.mp_draws.draw_landmarks(image, res, self.mp_hands.HAND_CONNECTIONS)
        return joint, angle

    def get_joint_from_landmarks_and_angle(self, landmarks):
        joint = np.zeros((21, 3))
        joint[:, 0] = np.array([lm.x for lm in landmarks])
        joint[:, 1] = np.array([lm.y for lm in landmarks])
        joint[:, 2] = np.array([lm.z for lm in landmarks])
        v = joint[[0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14, 16, 17, 18], :]
        - joint[[1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19], :]
        v = v / np.linalg.norm(v, axis=1, keepdims=True) + 1e-8
        angle = np.degrees(np.arctan2(np.linalg.norm(np.cross(v[:-1], v[1:]), axis=1), np.einsum('ij,ij->i', v[:-1], v[1:])))

        return joint, angle
    
class GestureManager:
    def __init__(self,
                 model_path,
                 sequence_length,
                 max_sequence_length):
        self.model_path = model_path
        self.sequence_length = sequence_length
        self.max_sequence_length = max_sequence_length
        self.model = load_model(self.model_path)
        self.buffer = []

    def append_data(self, data):
        self.buffer.append(data)
    
    def inference(self):
        if len(self.buffer) < 30: return
        input_data = np.expand_dims(np.array(self.buffer[-self.sequence_length:], dtype=np.float32), axis=0)
        result = self.model.predict(input_data, verbose=None).squeeze()
        return result
    
class ControlManager:
    def __init__(self,
                 pre_presets:dict={},
                 window_size = (320, 240)):
        self.presets = pre_presets
        self.window_size = window_size 

    def update_preset(self, alias, actions):
        self.presets[alias] = actions

    def delete_preset(self, alias):
        self.presets.pop(alias)

    def move_mouse(self, x, y):
        resized_x = x * self.window_size[0]
        resized_y = y * self.window_size[1]
        gui.moveTo(resized_x, resized_y, _pause=False)

    def run_actions(self, alias):
        if hasattr(self.presets, alias):
            # {'actions':[(gui.keypress, 'k'), (gui.mouseclick, 'left'), ...], ...}
            actions = getattr(self.presets, alias)
            for action in actions:
                method = action[0]
                args = action[1]
                if callable(method):
                    method(args)