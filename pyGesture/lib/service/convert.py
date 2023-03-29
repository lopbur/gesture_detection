import cv2
import numpy as np


reconstructed_data = bytearray()
def combineChunk(chunk: any, is_last_chunk: bool):
    """
        get seperated byte array and combine to full byte array.
        return full bytelist when got is_last_chunk flag is true
    """
    reconstructed_data.extend(chunk)
    if is_last_chunk:
        bytes_read = 0

        while bytes_read < len(reconstructed_data):
            # Extract the length of the next image
            length_bytes = reconstructed_data[bytes_read:bytes_read+4]
            length = int.from_bytes(length_bytes, byteorder='little')
            bytes_read += 4

            # Extract the next image data
            image_data = reconstructed_data[bytes_read:bytes_read+length]
            bytes_read += length

            # Decode the image using OpenCV
            nparr = np.frombuffer(image_data, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

# def convertBytelistToImage(byte, h, w, channel):
#     """
#         return specific channel that convert from bytelist.
#         default bytelist as yuv420 format
#     """

#     yuv = np.frombuffer(byte, dtype=np.uint8).reshape(h * 3 // 2, w)
   
#     if (channel == 'rgb'):
#         return cv2.cvtColor(yuv, cv2.COLOR_YUV2RGB_I420)
#     elif (channel == 'bgr'):
#         return cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420)
#     elif (channel == 'yuv'):
#         return yuv
