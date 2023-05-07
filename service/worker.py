import functools, os, traceback, pyautogui
import numpy as np
from service import _gl, _mg
from keras.models import load_model

GESTURE_MODEL_PATH = os.path.abspath(os.path.join(_gl.MODEL_FOLDER_NAME, _gl.GESTURE_MODEL_NAME))

def show_worker_info(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        i, o = args
        print(f"{func.__name__} started with arguments")
        print(f'input: {i}')
        print(f'output: {o}')
        return func(*args, **kwargs)
    return wrapper

@show_worker_info
def gesture_worker(i, o):
    MOVEMENT_THRESHOLD = 0.08
    prev_landmarks = None  # 이전 프레임의 랜드마크
    displacement = np.zeros((21, 3)) # 위치 변화량 저장하기 위한 배열
    recent = np.zeros((30, 77))
    o.put('testssds')
    model = load_model(GESTURE_MODEL_PATH)
    while True:
        try:
            input = i.get()
            if input is None: break
            landmark_flat = input[0].flatten()
            angle = input[1]
            frame = np.concatenate((landmark_flat, angle), axis=0)
            recent[:-1] = recent[1:]
            recent[-1] = frame
            result = model.predict(recent[np.newaxis, :, :], verbose=None).squeeze()
            if result is None:
                continue

            i_pred = int(np.argmax(result))

            confidence = result[i_pred]
            if confidence < 0.7:
                continue

            i_pred = int(np.argmax(result))

            o.put(i_pred)
            
        except KeyboardInterrupt:
            break
        except Exception as e:
            print('Error occurred. worker stopped.')
            print('Exception: {}'.format(str(e)))
            print(traceback.format_exc())
            while not i.empty():
                print(i.get())
            break


# def gesture_inference_worker(inputs, outputs, args):
#     print('Gesture inference worker started with')
#     print(f'input: {inputs}')
#     print(f'output: {outputs}')
#     gm = _mg.GestureManager(model_path=GESTURE_MODEL_PATH,
#                         sequence_length=30,
#                         max_sequence_length=100)
#     while True:
#         try:
#             input = inputs[0].get()
#             if input is None: break

#             gm.append_data(input)
#             result = gm.inference()

#             if result is None:
#                 continue

#             i_pred = int(np.argmax(result))

#             confidence = result[i_pred]
#             if confidence < 0.7:
#                 continue

#             i_pred = int(np.argmax(result))

#             outputs[0].put({'gesture': args[0][i_pred]})
#         except KeyboardInterrupt:
#             break

# def window_worker(inputs, outputs, args):
#     print('Window worker started with')
#     print(f'input: {inputs}')
#     print(f'output: {outputs}')
#     print(f'args: {args}')

#     gesture_event = args[0]
#     cm = _mg.ControlManager(gesture_events=gesture_event)
#     window_width, window_height = pyautogui.size()

#     gesture_buffer = np.array([], dtype=np.string_)

#     while True:
#         input = inputs[0].get()
#         if input is None: break

#         try:
#             if 'update_event' in input:
#                 cm.set_gesture_event(input['update_event'])

#             if 'landmark' in input:
#                 try:
#                     resized_x = input['landmark'][0] * window_width
#                     resized_y = input['landmark'][1] * window_height
#                     pyautogui.moveTo(resized_x, resized_y, _pause=False)
#                 except KeyError as e:
#                     print(f'Some error has occured while move mouse position to ({resized_x, resized_y}): {e}')
            
#             if 'gesture' in input:
#                 gesture_buffer = np.append(gesture_buffer, input['gesture'])

#                 if len(gesture_buffer) < 5:
#                     continue

#                 if np.all(gesture_buffer == input['gesture']):
#                     cm.action(input['gesture'])

#                 gesture_buffer = np.array([], dtype=np.string_)

#         except KeyboardInterrupt:
#             print('window worker get keyboard interrupted.')
#             break

#         # Gesture preset update command
#         if 'update_gesture' in input:
#             # [('alias, [(method, args), ...]), ...]
#             print(f'Gesture update command input: {input}')

#         # Gesture run action command -> run specific method
#         if 'gesture' in input:
#             print(f'Gesture command input: {input}')
#             cm.run_actions(input['gesture'])