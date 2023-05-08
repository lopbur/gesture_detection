import functools, os, traceback, time, pyautogui
import numpy as np
from service import _gl, _dio, _ps
from keras.models import load_model

GESTURE_MODEL_PATH = os.path.abspath(os.path.join(_gl.MODEL_FOLDER_NAME, _gl.GESTURE_MODEL_NAME))
GESTURE_LABEL_PATH = os.path.abspath(os.path.join(_gl.OLD_DATA_FOLDER_NAME, _gl.LABEL_NAME))

def show_worker_info(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        _i, _o, _args = args
        print(f"{func.__name__} started with arguments")
        print(f'input: {_i}')
        print(f'output: {_o}')
        print(f'args: {_args}')
        return func(*args, **kwargs)
    return wrapper


    MOVEMENT_THRESHOLD = 0.08
    displacement = np.zeros((21, 3)) # 위치 변화량 저장하기 위한 배열 
    prev_landmarks = None  # 이전 프레임의 랜드마크

@show_worker_info
def motion_worker(i, o, args):
    gesture_event_list = args['gesture_event_list']
    window_width, window_height = pyautogui.size()

    while True:
        try:
            input = i.get()
            if input is None: break
            landmarks = input[0]
            gesture = input[1]

            if landmarks is not None:
                mouse_base_landmark = input[0][0, :2]
                resized_x = mouse_base_landmark[0] * window_width
                resized_y = mouse_base_landmark[1] * window_height
                pyautogui.moveTo(resized_x, resized_y, _pause=False)

            if gesture is not None:
                _ps.send_event(gesture_event_list['gesture'])

        except KeyboardInterrupt:
            break
        except Exception as e:
            print('Error occurred. worker stopped.')
            print('Exception: {}'.format(str(e)))
            print(traceback.format_exc())
            while not i.empty():
                print(i.get())
            break


@show_worker_info
def gesture_worker(i, o, args):
    recent = np.zeros((30, 77))
    
    gesture_label_list, _ = _dio.load_gesture_label(GESTURE_LABEL_PATH)
    model = load_model(GESTURE_MODEL_PATH)

    DETECT_DELAY = 1
    detect_time = time.time()
    while True:
        try:
            input = i.get()
            if input is None: break

            landmark_flat = input[0].flatten()
            angle = input[1]
            frame = np.concatenate((landmark_flat, angle), axis=0)
            recent[:-1] = recent[1:]
            recent[-1] = frame

            cur_time = time.time()

            if cur_time - detect_time < DETECT_DELAY: continue
            result = model.predict(recent[np.newaxis, :, :], verbose=None).squeeze()

            i_pred = int(np.argmax(result))

            confidence = result[i_pred]
            if confidence < 0.7: continue
            
            cur_gesture = gesture_label_list[i_pred]
            detect_time = time.time()

            o.put((None, cur_gesture))
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