import numpy as np
import cv2

def byteToCV2List(byte):
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
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        data.append(img)
    return data