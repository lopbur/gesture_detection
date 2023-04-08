import mediapipe as mp
import numpy as np

import time

mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils
hands = mp_hands.Hands(
    max_num_hands = 1,
    min_detection_confidence = 0.5,
    min_tracking_confidence = 0.5
)

def getAngle(joint):
    """
    Get a list of degrees between each landmark and the previous landmark.

    Args:
        joint (numpy array): An array containing the coordinates of 21 landmarks in 3D or 4D
        - The shape should be (21, 3)(63, ) or (21, 4)(84,)

    Returns:
        Array of angle and joint values between each landmark -> (82,)
    """
    # Compute angles between joints -> (20, 3)
    # v = joint[[0,1,2,3,0,5,6,7,0,9,10,11,0,13,14,15,0,17,18,19], :] 
    # - joint[[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20], :]
    v = joint[[0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14, 16, 17, 18], :] - joint[[1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19], :]

    # Normalize v
    v = v / np.linalg.norm(v, axis=1, keepdims=True) + 1e-8
    
    # Get angle
    # Use arctan2 with range -pi/2 to pi/2 instead of arccos with range 0 to pi -> (19,)
    angle = np.degrees(np.arctan2(np.linalg.norm(np.cross(v[:-1], v[1:]), axis=1), np.einsum('ij,ij->i', v[:-1], v[1:])))

    # Concatenate joint positions and angles,
    # joint.flatten() -> (63,) (x, y, z coordinate values of 21 landmarks)
    joint_angle = np.concatenate([joint.flatten(), angle], axis=0)

    return joint_angle

