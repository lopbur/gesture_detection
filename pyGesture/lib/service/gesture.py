import numpy as np
from keras.models import load_model

seq = []
seq_length = 30

gesture_model = load_model('./models/model.h5')
actions = ['come', 'away', 'spin']

def predict(landmarks):
    landmark_preprocess(landmarks)

    if(len(seq) < seq_length): return 'None'
    input_data = np.expand_dims(np.array(seq[-seq_length:], dtype=np.float32), axis=0)

    y_pred = gesture_model.predict(input_data).squeeze()

    i_pred = int(np.argmax(y_pred))
    conf = y_pred[i_pred]

    return [actions[i_pred], conf.item()]


def landmark_preprocess(landmark):
    joint = np.zeros((21, 4))
    for i, el in enumerate(landmark):
        joint[i] = np.concatenate((el, [0.0]))
    
    # Compute angles between joints
    v1 = joint[[0,1,2,3,0,5,6,7,0,9,10,11,0,13,14,15,0,17,18,19], :3] # Parent joint
    v2 = joint[[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20], :3] # Child joint
    v = v2 - v1 # [20, 3]

    # Normalize v
    v = v / np.linalg.norm(v, axis=1)[:, np.newaxis]

    # Get angle using arcos of dot product
    angle = np.arccos(np.einsum('nt,nt->n',
        v[[0,1,2,4,5,6,8,9,10,12,13,14,16,17,18],:], 
        v[[1,2,3,5,6,7,9,10,11,13,14,15,17,18,19],:])) # [15,]

    angle = np.degrees(angle)
    d = np.concatenate([joint.flatten(), angle])

    seq.append(d)

    