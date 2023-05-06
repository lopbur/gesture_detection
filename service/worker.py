import numpy as np
import pyautogui
import os

from service import _mg, _gl

GESTURE_MODEL_PATH = os.path.abspath(os.path.join(_gl.MODEL_FOLDER_NAME, _gl.GESTURE_MODEL_NAME))

def gesture_inference_worker(inputs, outputs, args):
    print('Gesture inference worker started with')
    print('Window worker started with')
    print(f'input: {inputs}')
    print(f'output: {outputs}')
    print(f'args: {args}')
    gm = _mg.GestureManager(model_path=GESTURE_MODEL_PATH,
                        sequence_length=30,
                        max_sequence_length=100)
    while True:
        try:
            input = inputs[0].get()
            if input is None: break

            gm.append_data(input)
            result = gm.inference()

            if result is None:
                continue

            i_pred = int(np.argmax(result))

            confidence = result[i_pred]
            if confidence < 0.7:
                continue

            i_pred = int(np.argmax(result))

            outputs[0].put({'gesture': args[0][i_pred]})
        except KeyboardInterrupt:
            print('gesture worker Keyboard interrupted.')
            break

def window_worker(inputs, outputs, args):
    print('Window worker started with')
    print(f'input: {inputs}')
    print(f'output: {outputs}')
    print(f'args: {args}')

    gesture_event = args[0]
    cm = _mg.ControlManager(gesture_events=gesture_event)
    window_width, window_height = pyautogui.size()

    gesture_buffer = np.array([], dtype=np.string_)

    while True:
        input = inputs[0].get()
        if input is None: break

        try:
            if 'update_event' in input:
                cm.set_gesture_event(input['update_event'])

            if 'landmark' in input:
                try:
                    resized_x = input['landmark'][0] * window_width
                    resized_y = input['landmark'][1] * window_height
                    pyautogui.moveTo(resized_x, resized_y, _pause=False)
                except KeyError as e:
                    print(f'Some error has occured while move mouse position to ({resized_x, resized_y}): {e}')
            
            if 'gesture' in input:
                gesture_buffer = np.append(gesture_buffer, input['gesture'])

                if len(gesture_buffer) < 5:
                    continue

                if np.all(gesture_buffer == input['gesture']):
                    cm.action(input['gesture'])

                gesture_buffer = np.array([], dtype=np.string_)

        except KeyboardInterrupt:
            print('window worker get keyboard interrupted.')
            break

        # # Gesture preset update command
        # if 'update_gesture' in input:
        #     # [('alias, [(method, args), ...]), ...]
        #     print(f'Gesture update command input: {input}')

        # # Gesture run action command -> run specific method
        # if 'gesture' in input:
        #     print(f'Gesture command input: {input}')
        #     cm.run_actions(input['gesture'])