import cv2
import numpy as np

im = cv2.imread("bottom_text.png",0)
for li, l in enumerate(im):
    row = ""
    for pix in l:
        if pix > 128:
            row += "0"
        else:
            row += "1"
    rv = str(len(l))+ '\'b' + row
    print(f"assign imbus[{li}] = {rv};")