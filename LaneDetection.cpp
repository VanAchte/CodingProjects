#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>

using namespace std;
using namespace cv;

Mat yellowFilter(const Mat& src) {
	assert(src.type() == CV_8UC3);

	Mat yellowOnly;
	Mat src_blur, src_hls;
	//cvtColor(src, src_hsv, CV_BGR2HSV);
	//imshow()
	GaussianBlur(src, src_blur, Size(25, 25), 0, 0);
	//imshow("src_blur", src_blur);
	cvtColor(src_blur, src_hls, CV_BGR2HLS);
	//imshow("src_hls", src_hls);
	//inRange(src_blur, Scalar(0, 180, 225), Scalar(170, 255, 255), yellowOnly);

	inRange(src_hls, Scalar(20, 120, 80), Scalar(45, 200, 255), yellowOnly);
	return yellowOnly;
}

int main(int argc, char *argv[]) {
	Mat input = imread(argv[1]);
	if (input.empty()) {
		cout << "Error loading the image" << endl;
		exit(1);
	}
	//Mat input_blur;
	//imshow("input", input);
	//waitKey();

	//Mat yellowOnly = yellowFilter(input);

	//vector<Vec4i> lines;
	//double minLineLength = 100;
	//double maxLineGap = 15;
	//HoughLinesP(yellowOnly, lines, 1, CV_PI / 180, 80, minLineLength, maxLineGap);
	//for (size_t i = 0; i < lines.size(); i++) {
	//	//cout << lines[i] << endl;
	//	line(input, Point(lines[i][0], lines[i][1]),
	//		Point(lines[i][2], lines[i][3]), Scalar(0, 0, 255), 3, 8);
	//	circle(input, Point(lines[i][0], lines[i][1]), 5, (0, 0, 255), -1);
	//	circle(input, Point(lines[i][2], lines[i][3]), 5, (255, 0, 0), -1);
	//}
	//imshow("input", input);
	//imshow("yellowOnly", yellowOnly);
	//waitKey();

	VideoCapture cap("video3.mp4");
	if (!cap.isOpened()) {
		return -1;
	}
	// @processFrames: number of frames to skip processing as the camera is initially calibrating
	// @process count: counter for number of frames, set to 12 as a default
	int processFrames = 12;
	int processCount = 0;
	while (cap.isOpened()) {
		Mat frame;
		cap >> frame;
		if (frame.empty()) {
			break;
		}
		processCount++;
		if (processCount > processFrames) {

			// Masks image for yellow color
			Mat yellowOnly = yellowFilter(frame);
			// Draw a line across middle of frame for ROI
			line(frame, Point(0, 220),
				Point(640, 220), Scalar(0, 0, 0), 3, 8);
			// Draw line segments for left, right, and middle
			line(frame, Point(213, 220),
				Point(213, 480), Scalar(0, 0, 0), 3, 8);
			line(frame, Point(426, 220),
				Point(426, 480), Scalar(0, 0, 0), 3, 8);

			vector<Vec4i> lines;
			double minLineLength = 100;
			double maxLineGap = 10;
			HoughLinesP(yellowOnly, lines, 1, CV_PI / 180, 80, minLineLength, maxLineGap);
			for (size_t i = 0; i < lines.size(); i++) {
				//cout << lines[i] << endl;
				double longestLine = 0;
				int x1 = lines[i][0];
				int y1 = lines[i][1];
				int x2 = lines[i][2];
				int y2 = lines[i][3];
				
				// If the line is parallel and above the middle of the image continue through the loop
				if (y2 < 220 && y1 < 220) {
					continue;
				}

				Point a(x1, y1);
				Point b(x2, y2);
				double res = norm(a - b);
				cout << "res = " << res << endl;
				if (res > longestLine) {
					longestLine = res;
					line(frame, Point(x1, y1),
						Point(x2, y2), Scalar(0, 0, 255), 3, 8);
					circle(frame, Point(x1, y1), 5, (0, 0, 255), -1);
					circle(frame, Point(x2, y2), 5, (255, 0, 0), -1);
				}

			}

			imshow("yellowOnly", yellowOnly);
			imshow("frame", frame);
			if (waitKey(2) == 27) {
				break;
			}
		}
	}
	cap.release();
	destroyAllWindows();
	return 0;
}