import numpy as np
import pyautogui
import os, asyncio

from service import _mg, _gl

GESTURE_MODEL_PATH = os.path.abspath(os.path.join(_gl.MODEL_FOLDER_NAME, _gl.GESTURE_MODEL_NAME))

def gesture_inference_worker(inputs, outputs):
    print('Gesture inference worker started.')
    gm = _mg.GestureManager(model_path=GESTURE_MODEL_PATH,
                        sequence_length=30,
                        max_sequence_length=100)
    while True:
        input = inputs.get()
        if input is None: break
        gm.append_data(input)
        result = gm.inference()
        if result is not None:
            command = {
                'gesture': int(np.argmax(result))
            }
            outputs.put(command)

def window_worker(inputs, outputs):
    print('Window worker started.')
    cm = _mg.ControlManager()

    while True:
        input = inputs.get()
        if input is None: break

        try:
            resized_x = input[0] * 1600
            resized_y = input[1] * 900
            print(resized_x, resized_y)
            pyautogui.moveTo(resized_x, resized_y, _pause=False)
        except:
            pass

        # # Gesture preset update command
        # if 'update_gesture' in input:
        #     # [('alias, [(method, args), ...]), ...]
        #     print(f'Gesture update command input: {input}')

        # # Gesture run action command -> run specific method
        # if 'gesture' in input:
        #     print(f'Gesture command input: {input}')
        #     cm.run_actions(input['gesture'])