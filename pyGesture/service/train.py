import numpy as np
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split
from keras.utils import to_categorical
from keras.models import Sequential
from keras.layers import LSTM, Dense
from keras.callbacks import ModelCheckpoint, ReduceLROnPlateau


labelPath = 'data/labels.txt'
dataPath = 'data'

def getActionTuples():
    with open(labelPath, 'r') as f:
        lines = f.readlines()
        actions = [line.strip().split()[0] for line in lines]
        labels = [line.strip().split()[1] for line in lines]

    return actions, labels

def train():
    actions, labels = getActionTuples()

    data = np.concatenate([
        np.load(f'{dataPath}/seq_{action.strip()}.npy') for action in actions
    ], axis=0)
    actions = [label.strip() for label in labels]

    x_data = data[:, :, :-1]
    labels = data[:, 0, -1]
    
    y_data = to_categorical(labels, num_classes=len(actions))
    
    x_data = x_data.astype(np.float32)
    y_data = y_data.astype(np.float32)

    x_train, x_val, y_train, y_val = train_test_split(x_data, y_data, test_size=0.1, random_state=2022)

    model = Sequential([
        LSTM(64, activation='relu', input_shape=x_train.shape[1:3]),
        Dense(32, activation='relu'),
        Dense(len(actions), activation='softmax')
    ])

    model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['acc'])
    model.summary()

    history = model.fit(
        x_train,
        y_train,
        validation_data=(x_val, y_val),
        epochs=200,
        callbacks=[
            ModelCheckpoint('models/model.h5', monitor='val_acc', verbose=1, save_best_only=True, mode='auto'),
            ReduceLROnPlateau(monitor='val_acc', factor=0.5, patience=50, verbose=1, mode='auto')
        ]
    )