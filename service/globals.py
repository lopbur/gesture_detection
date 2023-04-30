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
MOTION_MOUSE_SECTION = 'MOTION_MOUSE'
GESTURE_EVENT_SECTION = 'CONTROL_SETTING'

# define config key and value type as tuples
USE_MOTION_TO_ACTIVE_MOUSE_CONTROL = ConfigValue(bool, 'use_motion_to_mouse_control', 'true')
USE_GESTURE_TO_ACTIVE_EVENT = ConfigValue(bool, 'use_gesture', 'true')
MOTION_BASE_LANDMARK_COORDINATE = ConfigValue(int, 'motion_base_landmark_index', '0')

# define config settings using variables and constants
CONFIG_PRESET = {
    MOTION_MOUSE_SECTION: [
        USE_MOTION_TO_ACTIVE_MOUSE_CONTROL,
        MOTION_BASE_LANDMARK_COORDINATE,
    ],
    GESTURE_EVENT_SECTION: [
        USE_GESTURE_TO_ACTIVE_EVENT,
    ]
}