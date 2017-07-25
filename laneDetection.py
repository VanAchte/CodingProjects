
import cv2
import numpy as np
from transform import four_point_transform
import argparse
import matplotlib.image as mpimg
from matplotlib import pyplot as plt

def apply_smoothing(image, kernel_size=15):
    """
    kernel_size must be positive and odd
    """
    return cv2.GaussianBlur(image, (kernel_size, kernel_size), 0)


# What if ROI doesnt contain any lane?
# we can assume that lane is at the rightmost
ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", help="path to the image file")
args = vars(ap.parse_args())
image = mpimg.imread(args["image"])

im = plt.imread(args["image"])
testImg = cv2.imread(args["image"])
imgEdges = cv2.Canny(testImg,100, 200)


gray = cv2.cvtColor(testImg,cv2.COLOR_BGR2GRAY)

# lower_yellow = np.array([20, 100, 100], dtype = 'uint8')
# upper_yellow = np.array([30, 255, 255], dtype='uint8')
# mask_yellow = cv2.inRange(img_hsv, lower_yellow, upper_yellow)
# mask_white = cv2.inRange(gray_image, 200, 255)
# mask_yw = cv2.bitwise_or(mask_white, mask_yellow)
# mask_yw_image = cv2.bitwise_and(gray_image, mask_yw)

edges = cv2.Canny(gray,215,315,apertureSize = 3)
smoothEdges = apply_smoothing(edges, 5)



minLineLength = 10
maxLineGap = 1
smoothLines = cv2.HoughLinesP(smoothEdges,1,np.pi/180,15,minLineLength,maxLineGap)
for x in range(0, len(smoothLines)):
    for x1,y1,x2,y2 in smoothLines[x]:
        cv2.line(testImg,(x1,y1),(x2,y2),(0,255,0),2)


# minLineLength = 5
# maxLineGap = 1
# lines = cv2.HoughLinesP(edges,1,np.pi/180,15,minLineLength,maxLineGap)
# for x in range(0, len(lines)):
#     for x1,y1,x2,y2 in lines[x]:
#         cv2.line(testImg,(x1,y1),(x2,y2),(0,255,0),2)

# cv2.imshow('Smooth Edges', smoothEdges)
# cv2.imshow('edges', edges)
# cv2.imshow('hough',testImg)
# cv2.waitKey(0)

#coord = [(0, 0), (450, 0), (0, 300), (450, 300)]


#lines = cv2.HoughLines(imgEdges, 1, np.pi / 180.0, 50, np.array([]), 100, 10)
#lines = cv2.HoughLinesP(imgEdges, 1, np.pi / 180.0, 50, np.array([]), 100, 10)
# taking input from user

# ax = plt.gca()
# fig = plt.gcf()
#implot = ax.imshow(lines)

# coord = []
# coord = [(241, 316), (438, 312), (602, 447), (54, 447)] DSCN0632
#coord = [(251, 314), (443, 306), (616, 435), (85, 445)]
coord = [(251, 314), (443, 306), (85, 445), (616, 435)]
#imageCoord = [(200, 200), (1200, 0), (1200, 700), (0, 700)]
imageCoord = [(400, 400), (1000, 400), (1100, 700), (200, 700)]
challCoord = [(531, 462), (772, 462), (1104, 666), (211, 666)]
# def onclick(event):
# 	if event.xdata != None and event.ydata != None :
# 		coord.append((int(event.xdata), int(event.ydata)))
# cid = fig.canvas.mpl_connect('button_press_event', onclick)

# plt.imshow(lines)
# plt.show()
# print(coord)

# warped = four_point_transform(image, np.array(challCoord))
# plt.imshow(testImg), plt.show()
# # plt.imshow(warped), plt.show()
# cv2.waitKey(0)
# cv2.destroyAllWindows()

cap = cv2.VideoCapture('testvideos/calibration/challenge.mp4')

while (cap.isOpened()):
    ret, frame = cap.read()
    if frame is None:
        break
    # roi = frame[250:480, 0:640]
    # cv2.circle(frame, (531, 462), 5, (0, 0, 255), -1)
    # cv2.circle(frame, (772, 462), 5, (0, 0, 255), -1)
    # cv2.circle(frame, (1104, 666), 5, (0, 0, 255), -1)
    # cv2.circle(frame, (211, 666), 5, (0, 0, 255), -1)
    cv2.imshow("Original", frame)
    warped = four_point_transform(frame, np.array(imageCoord))
    cv2.imshow('warped', warped)
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # houghline transform
    high_thresh, thresh_im = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    lowThresh = 0.5 * high_thresh
    edges = cv2.Canny(gray, 300, 400)
    kernel = np.ones((3, 3), np.uint8)
    dilation = cv2.dilate(edges, kernel, iterations=1)
    im = cv2.bilateralFilter(dilation, 5, 17, 17)
    # cv2.imshow('im',im)
    lines = cv2.HoughLinesP(im, 1, np.pi / 180.0, 50, np.array([]), 100, 10)
    min_x = 640
    if lines is not None:
        for [[x1, y1, x2, y2]] in lines:
            dx, dy = x2 - x1, y2 - y1
            angle = np.arctan2(dy, dx) * 180 / (np.pi)
            # print(angle)

            if angle > 0:
                # print(x2, y2)
                if abs(y2 - 210) <= 10 and x2 < min_x:
                    # print("yes")
                    min_x = x2

                cv2.line(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
        # print((min_x - 247.0) * (60.0 / 523.0))
    # font = cv2.FONT_HERSHEY_SIMPLEX
    # cv2.putText(frame,'Hello World!',(10,500), font, 1,(255,255,255),2)
    # cv2.imshow('edges', edges)
    # cv2.imshow('warped', warped)
    #cv2.imshow('frame', frame)
    # cv2.waitKey(0)
    # cv2.waitKey(0)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# stictching of closer line can be done after hough transform.

cap.release()
cv2.destroyAllWindows()