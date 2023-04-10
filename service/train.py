import mediapipe as mp
import numpy as np
import os, argparse

# Declaration to variable needed to creating data
SEQ_LENGTH = 30
ACTION_TIME = 10
MAX_SAVE_SEQ_LENGTH = 100

# Declaration of path
OLD_DATA_PATH = 'data_old'
NEW_DATA_PATH = 'data_new'
LABEL_NAME = 'labels.txt'
MODEL_PATH = 'models'

MP_HANDS = mp.solutions.hands
MP_DRAW = mp.solutions.drawing_utils
HANDS_INST = MP_HANDS.Hands(
    max_num_hands = 1,
    min_detection_confidence = 0.5,
    min_tracking_confidence = 0.5
)

def parse_arguments():
    """
    argument parser

    Returns:
        args (argparse.Namespace): Object to store parsed arguments
        - ('-n', action='store_true', help="store in newer data folder.")
        - ('-r', action='store_true', help="replace with new data.")
        - ('-collection_time', type=int, default=10, help='Time to collect data through camera')
    """
    parser = argparse.ArgumentParser(description="create data set.")
    parser.add_argument('-n', action='store_true', help="store in newer data folder.")
    parser.add_argument('-r', action='store_true', help="replace with new data.")
    parser.add_argument('-c', type=int, default=ACTION_TIME, help='Time to collect data through camera')
    args = parser.parse_args()
    
    return args

def init(path:str):
    """
    Initialized for data stored
    If data store folder does not exist, create new folder.
    and do the same for the label.

    Args:
        path (str): Root path to create folder to store data.

    Returns:
        None
    """
    print('initializing..')

    oldp = os.path.join(path, OLD_DATA_PATH, 'labels.txt')
    newp = os.path.join(path, NEW_DATA_PATH, 'labels.txt')

    if not os.path.exists(oldp):
        os.makedirs(os.path.join(path, OLD_DATA_PATH), exist_ok=True)
        open(oldp, 'w').close()
    
    if not os.path.exists(newp):
        os.makedirs(os.path.join(path, NEW_DATA_PATH), exist_ok=True)
        open(newp, 'w').close()

def load_gesture_data(path):
    """
    Return list of exist gesture data

    Args:
        path (str): Path of exist data folder.

    Returns:
        new_data (numpy.ndarray): combined exist data list.
    """
    files = os.listdir(path)
    result = [
        np.load(os.path.join(path, file)) for file in files if (file.endswith('.npy') and file.startswith('seq'))
    ]

    return result

def load_gesture_label(path):
    with open(path, 'r') as f:
        lines = f.readlines()
        actions, labels = zip(*[line.strip().split() for line in lines])
    return np.array(actions), np.array(labels)


def save_gesture(data, path:str, label:str, overwrite:bool=False, seq_length:int=SEQ_LENGTH):
    """
    store raw data

    Args:
        data (numpy array): array of data to store
        path (str): paht to save
        overwrite (bool): whethre to create a sequence data

    Returns:
        None
    """
    raw_path = os.path.join(path, f'raw_{label}.npy')
    seq_path = os.path.join(path, f'seq_{label}.npy')

    info_message = ''

    raw_data = np.array(data)
    if not overwrite:
        if os.path.exists(raw_path):
            old_raw_data = np.load(raw_path)
            old_seq_data = np.load(seq_path)
            info_message += f'Old: {old_raw_data.shape, old_seq_data.shape} -> '

            print(f"found {raw_path} already exist. try concatenating..")
            raw_data = np.concatenate([old_raw_data, raw_data], axis=0)
        else:
            print(f"Could not found {raw_path}.")

    seq_data = create_sequence_data(raw_data, seq_length)

    info_message += f'New: {raw_data.shape, seq_data.shape}'

    np.save(raw_path, raw_data)
    np.save(seq_path, seq_data)

    print(f'Successfully data saved. {info_message}')

def add_label_to_gesture_list(gesture_list, label_list):
    label_data = np.tile(label_list[:, np.newaxis, np.newaxis, np.newaxis], (1, gesture_list.shape[1], gesture_list.shape[2], 1))
    result = np.concatenate([gesture_list, label_data], axis=-1)
    return result
    

def generate_random_sample_from_gesture_list(gesture_list, sample_size):
    """
    제스쳐 리스트를 받아서 각 제스쳐 별로 랜덤하게 샘플을 추출해서 리스트로 반환

    Args:
        gesture_list (list): 제스쳐 데이터가 담긴 리스트
        sample_ratio (float): 각 제스쳐에서 추출할 샘플의 비율 (0 ~ 1)

    Returns:
        result (numpy.ndarray): 랜덤하게 추출된 샘플로 구성된 배열
    """
    # Generate data from ratio.
    # num_samples_per_gesture = np.floor(np.array([gesture_data.shape[0] for gesture_data in gesture_list]) * sample_ratio).astype(int)
    samples = np.array([gesture_data[np.random.randint(0, gesture_data.shape[0], sample_size)] for gesture_data in gesture_list])

    return samples

def get_joint_from_landmarks(res):
    """
    Return joint list from mediapipe hand model result.

    Args:
        res (```mediapipe~NormalizedLandmarkList```):landmark results

    Returns:
        joint (numpy.ndarray): x, y, z values of landmarks in the form of a numpy array
    """
    joint = np.zeros((21, 3))
    
    joint[:, 0] = np.array([lm.x for lm in res.landmark])
    joint[:, 1] = np.array([lm.y for lm in res.landmark])
    joint[:, 2] = np.array([lm.z for lm in res.landmark])
    
    return joint

def get_angle_from_joint(joint):
    """
    Return list of degrees between each landmark and the previous landmark.

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


def get_label_num(label:str, path:str):
    """
    Return the label number of the created data.
    If there is alreay exist the same label, that label number is returned.
    In case of a label that does not exist, a new label number is returned.

    Args:
        label (str): Label name of created data.
        path (str): Data stored path (root path)

    Returns:
        Integer that label number the created data will have.
    """
    oldp = os.path.join(path, OLD_DATA_PATH, 'labels.txt')
    newp = os.path.join(path, NEW_DATA_PATH, 'labels.txt')
    label_num = -1

    with open(oldp, 'r') as f1, open(newp, 'r') as f2:
        oldln = f1.readlines()
        newln = f2.readlines()
        oldlnum = len(oldln)
        newlnum = len(newln)

        for i, line in enumerate(oldln):
            if label in line:
                label_num = i

        for i, line in enumerate(newln):
            if label in line:
                label_num = i        

    return (label_num == -1, oldlnum + newlnum)

def create_sequence_data(data, seq_length=SEQ_LENGTH):
    """
    create sequence data

    Args:
        data (numpy array): array of data to create sequences
        seq_length: length of sequence

    Returns:
        list of created sequence data
    """
    n_sequences = len(data) - seq_length
    full_seq_data = np.zeros((n_sequences, seq_length, data.shape[1]))
    for i in range(n_sequences):
        full_seq_data[i] = data[i:i + seq_length]
    return full_seq_data