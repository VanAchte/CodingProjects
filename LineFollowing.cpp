//#include <iostream>
//#include <opencv2/core/core.hpp>
//#include <opencv2/highgui/highgui.hpp>
//#include "opencv2/imgproc/imgproc.hpp"
//#include <stdlib.h>
//#include <stdio.h>
//
//using namespace cv;
//using namespace std;
//
//Mat src, src_gray;
//Mat dst, detected_edges;
//
//int edgeThresh = 1;
//int lowThreshold = 69;
//int const max_lowThreshold = 200;
//int ratio = 3;
//int kernel_size = 3;
//char* window_name = "Edge Map";
//
//void CannyThreshold(int, void*) {
//	 //yellowuce noise with a kernel 3x3
//	blur(src_gray, detected_edges, Size(3, 3));
//	imshow("bluryellow", detected_edges);
//	 //Canny detector
//	Canny(detected_edges, detected_edges, lowThreshold, lowThreshold*ratio, kernel_size);
//
//	 //Using Canny's output as a mask, we d-isplay our result
//	dst = Scalar::all(0);
//
//	src.copyTo(dst, detected_edges);
//	imshow(window_name, dst);
//}
//int main(int argc, char *argv[]) {
//	cout << "Hello World" << endl;
//	/// Load an image
//	src = imread(argv[1]);
//
//	if (!src.data) {
//		return -1;
//	}
//
//	/// Create a matrix of the same type and size as src (for dst)
//	dst.create(src.size(), src.type());
//
//	/// Convert the image to grayscale
//	cvtColor(src, src_gray, CV_BGR2GRAY);
//
//	/// Create a window
//	namedWindow(window_name, CV_WINDOW_AUTOSIZE);
//
//	/// Create a Trackbar for user to enter threshold
//	createTrackbar("Min Threshold:", window_name, &lowThreshold, max_lowThreshold, CannyThreshold);
//
//	/// Show the image
//	CannyThreshold(0, 0);
//	Mat result;
//	Mat src_hsv;
//	cvtColor(src, src_hsv, CV_BGR2HSV);
//	//imshow("dst", dst);
//	int low_r = 133, low_g = 41, low_b = 23;
//	int high_r = 255, high_g = 150, high_b = 40;
//	//cvtColor(detected_edges, detected_edges, CV_BGR2HSV);
//	inRange(src_hsv, Scalar(low_b, low_g, low_r), Scalar(high_b, high_g, high_r), result);
//	//cvInRangeS(detected_edges, cvScalar(20, 100, 100), cvScalar(30, 255, 255), imgThreshed);
//	vector<Vec4i> lines;
//	HoughLinesP(detected_edges, lines, 1, CV_PI / 180, 80, 10, 100);
//	//for (size_t i = 0; i < lines.size(); i++) {
//	//	//cout << lines[i] << endl;
//	//	line(dst, Point(lines[i][0], lines[i][1]),
//	//		Point(lines[i][2], lines[i][3]), Scalar(0, 0, 255), 3, 8);
//	//}
//	imshow("src", src);
//	imshow("result", result);
//	imshow("src_hsv", src_hsv);
//
//	/// Wait until user exit program by pressing a key
//	waitKey(0);
//	return 0;
//}
//#include <opencv2/opencv.hpp>
//#include <iostream>
//
//using namespace std;
//using namespace cv;
//
//Mat img;
//Mat img_blur;
//Mat src, src_gray;
//Mat dst, detected_edges;
//
//int edgeThresh = 1;
//int lowThreshold = 10;
//int const max_lowThreshold = 200;
//int ratio = 3;
//int kernel_size = 3;
//char* window_name = "Edge Map";
//
//
//void CallBackFunc(int event, int x, int y, int flags, void* userdata)
//{
//	if (event == EVENT_MOUSEMOVE) {
//		cout << "Pixel (" << x << ", " << y << "): " << img.at<Vec3b>(y, x) << endl;
//	}
//}
//
//int main(int argc, char *argv[]) {
//	// Read image from file 
//
//	img = imread(argv[1]);
//	//blur(img, img_blur, Size(3, 3));
//	
//	//Canny(detected_edges, detected_edges, lowThreshold, lowThreshold*ratio, kernel_size);
//	// Check it loaded
//	cout << "program running" << endl;
//	if (img.empty()) {
//		cout << "Error loading the image" << endl;
//		exit(1);
//	}
//	GaussianBlur(img, img_blur, Size(29, 29), 0, 0);
//	Mat result;
//	Mat src_hsv;
//	cvtColor(img, src_hsv, CV_BGR2HSV);
//	//imshow("dst", dst);
//	int low_r = 133, low_g = 41, low_b = 23;
//	int high_r = 255, high_g = 150, high_b = 40;
//	//cvtColor(detected_edges, detected_edges, CV_BGR2HSV);
//	inRange(src_hsv, Scalar(low_b, low_g, low_r), Scalar(high_b, high_g, high_r), result);
//	imshow("ImageDisplay", result);
//	//Create a window
//	namedWindow("ImageDisplay", 1);
//
//	Canny(img_blur, detected_edges, lowThreshold, lowThreshold*ratio, kernel_size);
//	//createTrackbar("Min Threshold:", window_name, &lowThreshold, max_lowThreshold, CannyThreshold);
//	
//
//	// Register a mouse callback
//	setMouseCallback("ImageDisplay", CallBackFunc, nullptr);
//
//	vector<Vec4i> lines;
//	HoughLinesP(detected_edges, lines, 1, CV_PI / 180, 80, 1, 10);
//	for (size_t i = 0; i < lines.size(); i++) {
//		cout << "line drawn" << endl;
//		cout << lines[i] << endl;
//		line(detected_edges, Point(lines[i][0], lines[i][1]),
//			Point(lines[i][2], lines[i][3]), Scalar(0, 0, 255), 3, 8);
//	}
//	imshow("detected_edges2", detected_edges);
//
//	//imshow("ImageDisplay33", img);
//	// Main loop
//	while (true) {
//		
//		imshow("bluryellow image", img_blur);
//		//imshow("img", img);
//		waitKey(50);
//	}
//}
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>

using namespace std;
using namespace cv;

Mat yellowFilter(const Mat& src)
{
	assert(src.type() == CV_8UC3);

	Mat yellowOnly;
	Mat src_blur, src_hls;
	//cvtColor(src, src_hsv, CV_BGR2HSV);
	//imshow()
	GaussianBlur(src, src_blur, Size(1, 1), 0, 0);
	imshow("src_blur", src_blur);
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
	Mat input_blur;
	imshow("input", input);
	waitKey();

	Mat yellowOnly = yellowFilter(input);
	
	vector<Vec4i> lines;
	HoughLinesP(yellowOnly, lines, 1, CV_PI / 180, 80, 1, 10);
	for (size_t i = 0; i < lines.size(); i++) {
		cout << "line drawn" << endl;
		cout << lines[i] << endl;
		line(input, Point(lines[i][0], lines[i][1]),
			Point(lines[i][2], lines[i][3]), Scalar(0, 0, 255), 3, 8);
	}
	imshow("input", input);
	imshow("yellowOnly", yellowOnly);
	waitKey();

	// detect squares after filtering...

	return 0;
}