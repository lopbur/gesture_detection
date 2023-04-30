from cv2 import cvtColor, imdecode, COLOR_YUV2BGR_I420, COLOR_YUV2RGB_I420, IMREAD_COLOR
import argparse
import numpy as np

from service import _gl

def parse_arguments():
    """
    argument parser

    Returns:
        args (argparse.Namespace): Object to store parsed arguments
        - ('-n', action='store_true', help="store in newer data folder.")
        - ('-r', action='store_true', help="replace with new data.")
        - ('-collection_time', type=int, default=10, help='Time to collect data through camera')
    """
    parser = argparse.ArgumentParser(description="create data set.")
    parser.add_argument('-n', action='store_true', help="store in newer data folder.")
    parser.add_argument('-r', action='store_true', help="replace with new data.")
    parser.add_argument('-c', type=int, default=_gl.ACTION_TIME, help='Time to collect data through camera')
    args = parser.parse_args()
    
    return args

def get_joint_from_landmarks(res):
    """
    Return joint list from mediapipe hand model result.

    Args:
        landmarks (```mediapipe~NormalizedLandmarkList```):landmark results

    Returns:
        joint (numpy.ndarray): x, y, z values of landmarks in the form of a numpy array
    """
    joint = np.zeros((21, 3))
        
    joint[:, 0] = np.array([lm.x for lm in res.landmark])
    joint[:, 1] = np.array([lm.y for lm in res.landmark])
    joint[:, 2] = np.array([lm.z for lm in res.landmark])
    
    return joint

def get_angle_from_joint(joint):
    """
    Return list of degrees between each landmark and the previous landmark.

    Args:
        joint (numpy array): An array containing the coordinates of 21 landmarks in 3D or 4D
        - The shape should be (21, 3)(63, ) or (21, 4)(84,)

    Returns:
        Array of angle and joint values between each landmark -> (82,)
    """
    # Compute angles between joints -> (20, 3)
    # v = joint[[0,1,2,3,0,5,6,7,0,9,10,11,0,13,14,15,0,17,18,19], :] 
    # - joint[[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20], :]
    v = joint[[0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14, 16, 17, 18], :] 
    - joint[[1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19], :]

    # Normalize v
    v = v / np.linalg.norm(v, axis=1, keepdims=True) + 1e-8
    
    # Get angle use arctan2(range -pi/2 to pi/2), arccos(range 0 to pi) -> (19,)
    angle = np.degrees(np.arctan2(np.linalg.norm(np.cross(v[:-1], v[1:]), axis=1), np.einsum('ij,ij->i', v[:-1], v[1:])))

    # Concatenate joint positions and angles,
    # joint.flatten() -> (63,) (x, y, z coordinate values of 21 landmarks)
    joint_angle = np.concatenate([joint.flatten(), angle], axis=0)

    return joint_angle

def yuv420byte_to_yuv_rgb_bgr(byte, width, height):
    # convert byte stream to yuv420 format
    yuv = np.array(byte, dtype=np.uint8).reshape(height * 3 // 2, width)
    bgr = cvtColor(yuv, COLOR_YUV2BGR_I420) # for cv2 output
    rgb = cvtColor(yuv, COLOR_YUV2RGB_I420) # for hand model input
    return yuv, rgb, bgr

# define fybctuibs required for registering gestures 
def byte_to_CV2_list(byte):
    # Initialize variables
    bytes_read = 0
    data = []
    
    # Loop over the reconstructed data to extract the images
    while bytes_read < len(byte):
        # Extract the length of the next image
        length_bytes = byte[bytes_read:bytes_read+4]
        length = int.from_bytes(length_bytes, byteorder='little')
        bytes_read += 4

        # Extract the next image data
        image_data = byte[bytes_read:bytes_read+length]
        bytes_read += length

        # Decode the image using OpenCV
        nparr = np.frombuffer(image_data, np.uint8)
        img = imdecode(nparr, IMREAD_COLOR)

        data.append(img)
    return data
