#include "stdafx.h"
// LineDetectionMain.cpp : Defines the entry point for the console application.
//




#include <opencv2/core/core.hpp>
#include <opencv2/video/video.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>
#include <cstdlib>
#include <thread>
#include <chrono>
extern "C" {
#include "rs232.h"
}


#define DEG_PER_PIXEL		0.036
#define BUF_SIZE 		128

using namespace cv;
using namespace std;

const Scalar light_green = Scalar(100, 255, 0);
//const Scalar yellow = Scalar(0, 255, 255);
const Scalar red = Scalar(0, 0, 255);
int cport_nr = 24; /* /dev/ttyACM0 */


void detectLines(Mat& imgOriginal, int processCount, KalmanFilter &kf, Mat& state, Mat& meas, bool &found);
double getLength(Point p1, Point p2);
int getShiftAmount(int x);
Mat yellowFilter(const Mat& src);

void sendToArduino(float dist, float deg);
void receiveFromArduino();


Mat rotate(Mat src, double angle)
{
	if (src.empty()) {
		cout << "Error loading the image" << endl;
		exit(1);
	}
	Mat dst;
	Point2f pt(src.cols / 2., src.rows / 2.);
	Mat r = getRotationMatrix2D(pt, angle, 1.0);
	warpAffine(src, dst, r, Size(src.cols, src.rows));
	return dst;
}

int main(int argc, char* argv[]) {
	int bdrate = 57600; /* 9600 baud */

	char mode[] = { '8','N','1',0 }; // 8 data bits, no parity, 1 stop bit

	//if (RS232_OpenComport(cport_nr, bdrate, mode)) {
	//	cout << "Can not open comport\n";
	//    return 0;
	//}
	//Sleep(2000000);
									 //usleep(2000000);  /* waits 2000ms for stable condition */




	int stateSize = 6;
	int measSize = 4;

	cv::KalmanFilter kf(stateSize, measSize);

	cv::Mat state(stateSize, 1, CV_32F);  // [x,y,v_x,v_y,w,h]
	cv::Mat meas(measSize, 1, CV_32F);    // [z_x,z_y,z_w,z_h]
										  // [E_x,E_y,E_v_x,E_v_y,E_w,E_h]

										  // Transition State Matrix A
										  // Note: set dT at each processing step!
										  // [ 1 0 dT 0  0 0 ]
										  // [ 0 1 0  dT 0 0 ]
										  // [ 0 0 1  0  0 0 ]
										  // [ 0 0 0  1  0 0 ]
										  // [ 0 0 0  0  1 0 ]
										  // [ 0 0 0  0  0 1 ]
	cv::setIdentity(kf.transitionMatrix);

	// Measure Matrix H
	// [ 1 0 0 0 0 0 ]
	// [ 0 1 0 0 0 0 ]
	// [ 0 0 0 0 1 0 ]
	// [ 0 0 0 0 0 1 ]
	kf.measurementMatrix = cv::Mat::zeros(measSize, stateSize, CV_32F);
	kf.measurementMatrix.at<float>(0) = 1.0f;
	kf.measurementMatrix.at<float>(7) = 1.0f;
	kf.measurementMatrix.at<float>(16) = 1.0f;
	kf.measurementMatrix.at<float>(23) = 1.0f;

	// Process Noise Covariance Matrix Q
	// [ Ex   0   0     0     0    0  ]
	// [ 0    Ey  0     0     0    0  ]
	// [ 0    0   Ev_x  0     0    0  ]
	// [ 0    0   0     Ev_y  0    0  ]	cout << "Img center = " << imgXCenter << endl;
	// [ 0    0   0     0     Ew   0  ]
	// [ 0    0   0     0     0    Eh ]
	kf.processNoiseCov.at<float>(0) = 1e-2;
	kf.processNoiseCov.at<float>(7) = 1e-2;
	kf.processNoiseCov.at<float>(14) = 5.0f;
	kf.processNoiseCov.at<float>(21) = 5.0f;
	kf.processNoiseCov.at<float>(28) = 1e-2;
	kf.processNoiseCov.at<float>(35) = 1e-2;

	// Measures Noise Covariance Matrix R
	cv::setIdentity(kf.measurementNoiseCov, cv::Scalar(1e-1));
	//VideoCapture capture(0);
	VideoCapture capture("soccer7.mp4");
	Mat frame;
	Mat flipped;
	double ticks = 0;
	bool found = false;
	

	// If the video is upside down, we use this to flip it rightside up
	
	//cv::Flip(frame, flipMode = -1)
	int processCount = 0;
	while (true) {
		double precTicks = ticks;
		ticks = (double)getTickCount();
		double dT = (ticks - precTicks) / getTickFrequency();


		capture >> frame;
		flipped = rotate(frame, 180);
		imshow("flipped", flipped);

		if (found) {
			kf.transitionMatrix.at<float>(2) = dT;
			kf.transitionMatrix.at<float>(9) = dT;
			state = kf.predict();

			cv::Rect predRect;
			predRect.width = state.at<float>(4);
			predRect.height = state.at<float>(5);
			predRect.x = state.at<float>(0) - predRect.width / 2;
			predRect.y = state.at<float>(1) - predRect.height / 2;

			cv::Point center;
			center.x = state.at<float>(0);
			center.y = state.at<float>(1);
			float degrees = DEG_PER_PIXEL * (center.x - 320);
			cout << "Predicted degrees " << degrees << endl;
		}


		//detectLines(frame, processCount, kf, state, meas, found);
		detectLines(flipped, processCount, kf, state, meas, found);
		if (cv::waitKey(1) == 'p')
			while (cv::waitKey(1) != 'p');
		//imshow("flipped", flipped);
		//detectLines(frame, processCount);
		processCount++;
		if (waitKey(20) == 27)
			break;
	}
	
	capture.release();
	return 0;
}

Mat blurImage(Mat input) {
	Mat blur_input;
	GaussianBlur(input, blur_input, Size(3, 3), 0, 0);
	return blur_input;
}



void detectLines(Mat& input, int processCount, KalmanFilter &kf, Mat& state, Mat& meas, bool &found) {
	//cout << processCount << endl;
	if (input.empty()) {
		cout << "Error loading the image" << endl;
		exit(1);
	}

	// Masks image for yellow color
	Mat yellowOnly = yellowFilter(input);
	imshow("yellowOnly", yellowOnly);
	Mat yellowBlur = blurImage(yellowOnly);
	imshow("yellowBlur", yellowBlur);


	//////////////////////////////////////////////
	int thresh = 30;
	Mat canny_output;
	Mat imgContours;
	vector<vector<Point>> contours;
	vector<Vec4i> hierarchy;

	findContours(yellowBlur.clone(), contours, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE, Point(0, 0));
	vector<vector<Point> > hulls(contours.size());
	imgContours = Mat::zeros(yellowBlur.size(), CV_8UC3);


	int area = INT_MIN;
	int largestContour = 0;
	int size = contours.size();
	Point center;
	for (size_t i = 0; i < size; i++) {
		approxPolyDP(contours[i], contours[i], 9.0, true);
		convexHull(Mat(contours[i]), hulls[i], CV_CLOCKWISE);
		int curArea = contourArea(contours[i]);
		if (curArea > area) {
			area = curArea;
			largestContour = i;
		}
	}

	//for (size_t i = 0; i < size; i++) {
		//drawContours(imgContours, contours, i, light_green, 1, 8, hierarchy, 0, Point());
		//drawContours(imgAllConvexHulls, hulls, i, yellow, 1, 8, hierarchy, 0, Point());
			//drawContours(imgConvexHulls3to10, hulls, i, red, 1, 8, hierarchy, 0, Point());
		//drawContours(imgContours, hulls, i, Scalar(255, 255, 255), 1, 8, hierarchy, 0, Point());
	if (size > 0) {
	    drawContours(input, hulls, largestContour, Scalar(255, 0, 255), 1, 8, hierarchy, 0, Point());

	    Moments m = moments(hulls[largestContour], false);
		int cX = m.m10 / m.m00;
		int cY = m.m01 / m.m00;
		// get rectangle and center
		Rect rectangle = boundingRect(hulls[largestContour]);
		center = Point(cX, cY);
    }
		//cout << "(" << center.x << ", " << center.y << ")";
		//cout << "\tDistance, degrees: " << distance << ", " << degrees << endl;
		//cones.push_back(make_pair(rectangle, center));
		
	//}
	float offset = 90;
	// pixPerDegree was calculated by taking the 180 degrees of turning and normalizing it with the amount of
	// pixels seen in the image taken by the raspberry pi, which is 640 * 480. So by dividing 640 with 180 we get 3.55,
	// the amount of pixels per degree
	double pixPerDegree = 3.55;
	if (size > 0) {
		if (center.x < 320) {
			offset = 180 - (center.x / pixPerDegree);
		}
		else if (center.x > 320) {
			offset = 180 - (center.x / pixPerDegree);
		}
	}


	//float degrees = DEG_PER_PIXEL * (midX - 320);
	//cout << "degrees = " << degrees << endl;
	//int distance = botTemp.x - 320;
	//cout << "distance = " << distance << endl;

	//cout << "degrees = " << degrees << endl;
	//cout << "degrees servo num = " << degrees * 40 + 1100;
	//sendToArduino(distance, degrees);
	//receiveFromArduino();
	imshow("input", input);

}





Mat yellowFilter(const Mat& src) {
	assert(src.type() == CV_8UC3);

	Mat yellowOnly;
	Mat src_hls;
	Mat imgThreshLow, imgThreshHigh, imgThreshSmooth;
	
	cvtColor(src, src_hls, CV_BGR2HLS);
	rectangle(src_hls, Point(0, 0),
		Point(640, 240), Scalar(0, 0, 0), CV_FILLED, 8);

	//inRange(src_hls, Scalar(20, 120, 80), Scalar(45, 200, 255), yellowOnly);
	//inRange(src_hls, Scalar(20, 100, 100), Scalar(30, 255, 255), yellowOnly);
	
	//good inrange for video
	inRange(src_hls, Scalar(0, 80, 200), Scalar(40, 255, 255), imgThreshLow);

	//test inrange
	//inRange(src_hls, Scalar(20, 100, 100), Scalar(30, 255, 255), imgThreshLow);
	//inRange(src_hls, Scalar(184, 135, 117), Scalar(189, 255, 255), imgThreshHigh);

	Mat imgThresh = imgThreshLow;// | imgThreshHigh;
	erode(imgThresh, imgThreshSmooth, getStructuringElement(MORPH_RECT, Size(3, 3)));
	dilate(imgThreshSmooth, imgThreshSmooth, getStructuringElement(MORPH_RECT, Size(3, 3)));
	return imgThreshSmooth;
}

int getShiftAmount(int x) {
	// We want to shift the x into the middle to figure out the angle that would be made between these two lines
	int shiftTarget = 320;
	return shiftTarget - x;
}

double getLength(Point p1, Point p2) {
	int xVal = pow(p2.x - p1.x, 2);
	int yVal = pow(p2.y - p1.y, 2);
	int distance = sqrt(xVal + yVal);
	return distance;
}

void sendToArduino(float dist, float deg) {
	int i_deg = (int)deg + 10;
	if (i_deg < 0) i_deg = 0;
	string send_str = to_string((int)dist) + "," + to_string(i_deg) + "\n";
	RS232_cputs(cport_nr, send_str.c_str());
	cout << "Sent to Arduino: " << send_str;
	//usleep(8000);
	Sleep(8000);
}

void receiveFromArduino() {
	unsigned char str_recv[BUF_SIZE]; // recv data buffer
	int n = RS232_PollComport(cport_nr, str_recv, (int)BUF_SIZE);
	if (n > 0) {
		str_recv[n] = 0;   // put null at end
		cout << "Received " << n << " bytes: " << (char *)str_recv << "\n";
	}
}

