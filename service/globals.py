# develop
DEVELOP_MODE = True

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

ConfigValue = namedtuple('ConfigValue', ['type', 'name', 'default'])

# define config section keys as constants
CLIENT_SECTION = 'CLIENT'
MOTION_MOUSE_SECTION = 'MOTION_MOUSE'
GESTURE_EVENT_SECTION = 'CONTROL_SETTING'

# define config key and value type as tuples
# [CLIENT]
SHOW_LANDMARK_INFERENCE = ConfigValue(bool, 'show_landmark', 'False') # for low performance enviroment
SHOW_GESTURE_INFERENCE = ConfigValue(bool, 'show_gesture', 'False')

# [MOTION_MOUSE]
USE_MOTION_TO_ACTIVE_MOUSE_CONTROL = ConfigValue(bool, 'use_motion_to_mouse_control', 'True')
MOTION_BASE_LANDMARK_COORDINATE = ConfigValue(int, 'motion_base_landmark_index', '23')

# [CONTROL_SETTING]
USE_GESTURE_TO_ACTIVE_EVENT = ConfigValue(bool, 'use_gesture', 'True')
STOP_MOTION_WHILE_GESTURE = ConfigValue(bool, 'stop_motion_while_gesture', 'False')

# define config settings using variables and constants
CONFIG_PRESET = {
    CLIENT_SECTION: [
        SHOW_LANDMARK_INFERENCE,
        SHOW_GESTURE_INFERENCE,
    ],
    MOTION_MOUSE_SECTION: [
        USE_MOTION_TO_ACTIVE_MOUSE_CONTROL,
        MOTION_BASE_LANDMARK_COORDINATE,
    ],
    GESTURE_EVENT_SECTION: [
        USE_GESTURE_TO_ACTIVE_EVENT,
        STOP_MOTION_WHILE_GESTURE,
    ]
}