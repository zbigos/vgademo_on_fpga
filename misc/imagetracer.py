import cv2
import numpy as np

img = cv2.imread("mikoto.png")
scale_percent = 30
width = int(img.shape[1] * scale_percent / 100)
height = int(img.shape[0] * scale_percent / 100)
dim = (width, height)
img = cv2.resize(img, dim, interpolation = cv2.INTER_AREA)
ppath = []

def click_event(event, x, y, flags, params):
    global img
    global ppath
    
    if event == cv2.EVENT_LBUTTONDOWN:
        ppath.append((x, y))
        for i in range(len(ppath) - 1):
            img = cv2.line(img, ppath[i], ppath[i+1], (0, 0, 255), 2)
        cv2.imshow("aaaaa", img)
    
    with open("dump.txt", "w") as f:
        for p in ppath:
            f.write(f"{p[0]}: -{p[1]}\n")

cv2.imshow("aaaaa", img)
cv2.setMouseCallback("aaaaa", click_event)
cv2.waitKey(0)
