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

	GaussianBlur(src, src_blur, Size(25, 25), 0, 0);
	cvtColor(src_blur, src_hls, CV_BGR2HLS);
	rectangle(src_hls, Point(0, 0),
		Point(640, 240), Scalar(0, 0, 0), CV_FILLED, 8);
	//imshow("src_hls with black rect", src_hls);
	//waitKey(0);

	//inRange(src_hls, Scalar(20, 120, 80), Scalar(45, 200, 255), yellowOnly);
	inRange(src_hls, Scalar(20, 100, 100), Scalar(30, 255, 255), yellowOnly);
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

	VideoCapture cap("video7.mp4");
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

			//////////////////////////////////////////////
			int thresh = 50;
			Mat input_blur;
			GaussianBlur(input, input_blur, Size(25, 25), 0, 0);
			Mat canny_output;
			vector<vector<Point> > contours;
			vector<Vec4i> hierarchy;


			/// Detect edges using canny
			Canny(yellowOnly, canny_output, thresh, thresh * 2, 3);
			/// Find contours
			findContours(yellowOnly, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0));

			Vec4f fitLines;
			

			/// Draw contours
			Mat drawing = Mat::zeros(canny_output.size(), CV_8UC3);
			for (int i = 0; i < contours.size(); i++) {
				Scalar color = Scalar(0, 0, 255);
				//cout << "contours[" << i << "] = " << contours[i][0] << endl;
				//fitLine(fitLines, Mat(contours[i]), CV_DIST_L2, 0, .01,.01);
				drawContours(drawing, contours, i, color, -1, 8, hierarchy, 0, Point());
				
				imshow("Contours", drawing);
				
				//waitKey(0);
			}

			/////////////////////////////////////////////
			



			// Create a vectorwhich contains 4 integers in each element (coordinates of the line)
			vector<Vec4i> lines;
			// Set limits on line detection
			double minLineLength = 80;
			double maxLineGap = 5;
			
			HoughLinesP(yellowOnly, lines, 1, CV_PI / 180, 80, minLineLength, maxLineGap);
			double longestLine = 0;
			for (size_t i = 0; i < lines.size(); i++) {
				//cout << lines[i] << endl;
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
				longestLine = res;
				line(frame, Point(x1, y1),
				Point(x2, y2), Scalar(0, 0, 255), 3, 8);
				circle(frame, Point(x1, y1), 5, (0, 0, 255), -1);
				circle(frame, Point(x2, y2), 5, (255, 0, 0), -1);

			}
			imshow("canny_output", canny_output);
			imshow("yellowOnly", yellowOnly);
			imshow("frame", frame);
			if (waitKey(1) == 27) {
				break;
			}
		}
	}
	cap.release();
	//destroyAllWindows();
	return 0;
}