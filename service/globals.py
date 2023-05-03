# develop
DEVELOP_MODE = False

# declaration of regex training data file name
FILE_PATTERN = r'seq_([a-zA-Z]+).npy'
ACTION_TIME = 5

#############
# LOAD FILE #
#############
# declaration of address
BASE_GESTURE_MODEL_NAME = 'base_model.h5'
GESTURE_MODEL_NAME = 'base_model.h5'
MODEL_FOLDER_NAME = 'models'
OLD_DATA_FOLDER_NAME = 'data_old'
NEW_DATA_FOLDER_NAME = 'data_new'
LABEL_NAME = 'labels.txt'
CONFIG_PATH = './settings/default.ini'

##########
# CONFIG #
##########
from collections import namedtuple

CONFIG = namedtuple('config', ['dtype', 'name', 'default', ], defaults=[bool, 'nonameconfig', False])

# define config section keys as constants
CLIENT_SECTION = 'CLIENT'
CONTROL_SECTION = 'CONTROL_SETTING'
GESTURE_EVENT_SECTION = 'GESTURE_EVENT'

# define config key and value type as tuples
# [CLIENT]
SHOW_LANDMARK_INFERENCE = CONFIG(dtype=bool, name='show_landmark', default='False') # for low performance enviroment
SHOW_GESTURE_INFERENCE = CONFIG(dtype=bool, name='show_gesture', default='False')

# [MOTION_MOUSE]
USE_MOTION_TO_ACTIVE_MOUSE_CONTROL = CONFIG(dtype=bool, name='use_motion_to_mouse_control', default='True')
MOTION_BASE_LANDMARK_COORDINATE = CONFIG(dtype=int, name='motion_base_landmark_index', default='23')

# [CONTROL_SETTING]
USE_GESTURE_TO_ACTIVE_EVENT = CONFIG(dtype=bool, name='use_gesture', default='True')
STOP_MOTION_WHILE_GESTURE = CONFIG(dtype=bool, name='stop_motion_while_gesture', default='False')
# define config settings using variables and constants
CONFIG_PRESET = {
    CLIENT_SECTION: [
        SHOW_LANDMARK_INFERENCE,
        SHOW_GESTURE_INFERENCE,
    ],
    CONTROL_SECTION: [
        USE_GESTURE_TO_ACTIVE_EVENT,
        USE_MOTION_TO_ACTIVE_MOUSE_CONTROL,
        STOP_MOTION_WHILE_GESTURE,
        MOTION_BASE_LANDMARK_COORDINATE,
    ],
    GESTURE_EVENT_SECTION: [],
}