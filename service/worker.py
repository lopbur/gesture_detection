import numpy as np
import pyautogui
import os

from service import _mg, _gl

GESTURE_MODEL_PATH = os.path.abspath(os.path.join(_gl.MODEL_FOLDER_NAME, _gl.GESTURE_MODEL_NAME))

def gesture_inference_worker(inputs, outputs, args):
    print('Gesture inference worker started.')
    gm = _mg.GestureManager(model_path=GESTURE_MODEL_PATH,
                        sequence_length=30,
                        max_sequence_length=100)
    while True:
        try:
            input = inputs[0].get()
            if input is None: break
            gm.append_data(input)
            result = gm.inference()
            if result is not None:
                i_pred = int(np.argmax(result))

                outputs[1].put({'gesture': args[0][i_pred]})
        except KeyboardInterrupt:
            print('gesture worker Keyboard interrupted.')
            break

def window_worker(inputs, outputs, args):
    print('Window worker started.')
    cm = _mg.ControlManager()

    while True:
        input = inputs[0].get()
        if input is None: break

        try:
            if 'landmark' in input:
                resized_x = input[0] * 1600
                resized_y = input[1] * 900
                pyautogui.moveTo(resized_x, resized_y, _pause=False)
            
            if 'gesture' in input:
                print(input['gesture'])
        except KeyboardInterrupt:
            print('window worker Keyboard interrupted.')
            break

        # # Gesture preset update command
        # if 'update_gesture' in input:
        #     # [('alias, [(method, args), ...]), ...]
        #     print(f'Gesture update command input: {input}')

        # # Gesture run action command -> run specific method
        # if 'gesture' in input:
        #     print(f'Gesture command input: {input}')
        #     cm.run_actions(input['gesture'])