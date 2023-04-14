import numpy as np
import os
import service.globals as _g

###########################################
# INIT DATA STORE PATH, LOAD OR SAVE DATA #
###########################################
def create_data_init(*folder_paths:str):
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

    for path in folder_paths:
        label_path = os.path.join(path, _g.LABEL_NAME)
        os.makedirs(path, exist_ok=True)
        if not os.path.exists(label_path): open(label_path, 'w').close()

def safe_load_gesture_data(path):
    files = os.listdir(path)
    result = [(file, np.load(os.path.join(path, file))) for file in files if (file.endswith('.npy') and file.startswith('seq'))]
    
    return result

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

def load_gesture_label(*paths):
    actions = np.empty(0, dtype=str)
    labels = np.empty(0, dtype=str)
    
    for path in paths:
        with open(path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            _actions, _labels = zip(*[line.strip().split() for line in lines])
            actions = np.append(actions, _actions)
            labels = np.append(labels, _labels)
    return actions, labels


def save_gesture(data, path:str, label:str, seq_length:int=30, overwrite:bool=False):
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

def get_label_num(label:str, path:str):
    """
    Return the label number for created data.
    If there is alreay exist the same label, that label number is returned.
    In case of a label that does not exist, a new label number is returned.

    Args:
        label (str): Label name of created data.
        path (str): Data stored path (root path)

    Returns:
        Integer that label number the created data will have.
    """
    oldp = os.path.abspath(os.path.join(_g.OLD_DATA_FOLDER_NAME, _g.LABEL_NAME))
    newp = os.path.abspath(os.path.join(_g.NEW_DATA_FOLDER_NAME, _g.LABEL_NAME))
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

def add_label_to_gesture_list(gesture_list, label_list):
    label_data = np.tile(label_list[:, np.newaxis, np.newaxis, np.newaxis], (1, gesture_list.shape[1], gesture_list.shape[2], 1))
    result = np.concatenate([gesture_list, label_data], axis=-1)
    return result

##############################################
# GENERATE DATA FROM EXIST DATA OR NEW INPUT #
##############################################
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

def safe_generate_random_sample_from_gesture_list(gesture_list, sample_size):
    return

def create_sequence_data(data, seq_length):
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