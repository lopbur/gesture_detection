import os, argparse
import numpy as np

# Declaration to variable needed to creating data
seq_length = 30
action_time = 10

# Declaration of path
old_data_path = 'data_old'
new_data_path = 'data_new'
model_path = 'models'

def init(path:str):
    print('initializing..')

    oldp = os.path.join(path, old_data_path, 'labels.txt')
    newp = os.path.join(path, new_data_path, 'labels.txt')

    if not os.path.exists(oldp):
        os.makedirs(os.path.join(path, old_data_path), exist_ok=True)
        open(oldp, 'w').close()
    
    if not os.path.exists(newp):
        os.makedirs(os.path.join(path, new_data_path), exist_ok=True)
        open(newp, 'w').close()

def get_label_num(label:str, path:str):
    oldp = os.path.join(path, old_data_path, 'labels.txt')
    newp = os.path.join(path, new_data_path, 'labels.txt')
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

def create_sequence_data(data, seq_length=seq_length):
    """
    create sequence data

    Args:
        data (numpy array): array of data to create sequences
        seq_length: length of sequence

    Returns:
        created sequence data
    """
    n_sequences = len(data) - seq_length
    full_seq_data = np.zeros((n_sequences, seq_length, data.shape[1]))
    for i in range(n_sequences):
        full_seq_data[i] = data[i:i + seq_length]
    return full_seq_data

def save_gesture(data, path:str, label:str, overwrite:bool=False, seq_length:int=seq_length):
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
    parser.add_argument('-c', type=int, default=action_time, help='Time to collect data through camera')
    args = parser.parse_args()
    
    return args
