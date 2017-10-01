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
const Scalar yellow = Scalar(0, 255, 255);
const Scalar red = Scalar(0, 0, 255);
int cport_nr = 24; /* /dev/ttyACM0 */


void detectLines(Mat& imgOriginal, int processCount);
void sendToArduino(float dist, float deg);
void receiveFromArduino();


// Method is a work in progres, may end up being scrapped
// @@param int midX: the middle of the found lines mid
void getTurningAngle(int midX, int angle, Point top, Point bot) {
	// @@ int desiredAngle: set to the desired angle
	// @@ int desiredMidXVal: ideal mid value, for example, 320 for the middle of the frame
	int desiredAngle = 0;
	int desiredMidXVal = 320;

	// Check if the line is in the go straight boundaries
	if (midX >= 220 && midX <= 420) {
		//Possible go straight, check the angle
		if (angle <= 20) {
			// Good chance of going straight
			// TODO: Send command to trike to continue course
			cout << "Go Straight" << endl;
		}
		// If the angle is in the center constraints and is between 20 and 30 we assume the
		// turn will be a slight adjustment. Turn slightly towards the middle of the line detected
		else if (angle > 20 && angle <= 30) {
			// If the line is facing towards the middle of the image, example: \ 
			if ((top.x < bot.x) && midX > 320) {
				cout << "Slight right turn" << endl;
			}

			else if ((top.x < bot.x) && midX < 320) {

				cout << "Slight left turn" << endl;
			}
		}
		// If the angle is greater than 30 then a moderate turn is needed
		else if (angle > 30) {
			// Moderate turn left if the angle
			if (top.x < bot.x) {
				cout << "Moderate turn left" << endl;
			}
			else {
				cout << "Moderate turn right" << endl;
			}
		}
	}
	// If line is found on the left side of the screen
	else if (midX < 220) {
		// If the line is facing to the left side of the screen, example: \ 
		if (top.x < bot.x) {
			// Turn left
			cout << "Turn left" << endl;
		}
		else {
			// Line is facing towards the middle of the screen, example: / 
			// Possibley turn right in this case

		}
	}
	else if (midX > 420) {
		// If the line is in the right side of the image we are probable going to turn right
		cout << "Turn right" << endl;
	}



}
Mat yellowFilter(const Mat& src) {
	assert(src.type() == CV_8UC3);

	Mat yellowOnly;
	Mat src_blur, src_hls;

	GaussianBlur(src, src_blur, Size(25, 25), 0, 0);
	cvtColor(src_blur, src_hls, CV_BGR2HLS);
	rectangle(src_hls, Point(0, 0),
		Point(640, 240), Scalar(0, 0, 0), CV_FILLED, 8);

	//inRange(src_hls, Scalar(20, 120, 80), Scalar(45, 200, 255), yellowOnly);
	//inRange(src_hls, Scalar(20, 100, 100), Scalar(30, 255, 255), yellowOnly);
	inRange(src_hls, Scalar(0, 80, 200), Scalar(40, 255, 255), yellowOnly);
	return yellowOnly;
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
int main(int argc, char* argv[]) {
	int bdrate = 57600; /* 9600 baud */

	char mode[] = { '8','N','1',0 }; // 8 data bits, no parity, 1 stop bit

	if (RS232_OpenComport(cport_nr, bdrate, mode))
	{
		cout << "Can not open comport\n";
		return 0;
	}

	usleep(2000000);  /* waits 2000ms for stable condition */

	VideoCapture capture(0);
	Mat frame;
	int processCount = 0;
	while (true) {
		capture >> frame;
		detectLines(frame, processCount);
		processCount++;
		if (waitKey(20) == 27)
			break;
	}
	capture.release();
	return 0;
}



void detectLines(Mat& input, int processCount) {
	if (input.empty()) {
		cout << "Error loading the image" << endl;
		exit(1);
	}



	int numAvgLines = 0;
	Point topAvg(0, 0);
	Point botAvg(0, 0);
	Point topTemp(0, 0);
	Point botTemp(0, 0);

	// For triangle calibration to help eliminate issues with jumping line
	// @@ int prevY: Y value for previous frame from triangle
	// @@ int currentY: current Y value for the frame
	int prevY = -1;
	int currentY = -1;
	int xVals[] = { 0, 0, 0, 0 };






	// Masks image for yellow color
	Mat yellowOnly = yellowFilter(input);

	//// Draws a line straight down middle of screen as a reference line
	//line(frame, Point(320, 0),
	//	Point(320, 480), Scalar(0, 0, 0), 3, 8);
	//// Draws two lines in prospective straight area
	//line(frame, Point(220, 0),
	//	Point(220, 480), Scalar(0, 0, 0), 3, 8);
	//line(frame, Point(420, 0),
	//	Point(420, 480), Scalar(0, 0, 0), 3, 8);


	//////////////////////////////////////////////
	int thresh = 50;
	Mat input_blur;
	GaussianBlur(input, input_blur, Size(25, 25), 0, 0);
	Mat canny_output;
	//vector<vector<Point>> contours;
	//vector<Vec4i> hierarchy;


	/// Detect edges using canny
	Canny(yellowOnly, canny_output, thresh, thresh * 2, 3);


	// Create a vectorwhich contains 4 integers in each element (coordinates of the line)
	vector<Vec4i> lines;

	//float testAngle = atan2(-1 - -1, 2 - 10);
	//cout << "testAngle = " << testAngle << endl;
	// Set limits on line detection
	//Good value here
	//double minLineLength = 80;
	double minLineLength = 80;
	double maxLineGap = 5;

	HoughLinesP(yellowOnly, lines, 1, CV_PI / 180, 80, minLineLength, maxLineGap);

	int numLines = lines.size();
	double longestLine = 0;

	Point highestPoint(0, 0);
	Point lowestPoint(0, 0);

	for (size_t i = 0; i < numLines; i++) {
		//cout << lines[i] << endl;
		int x1 = lines[i][0];
		int y1 = lines[i][1];
		int x2 = lines[i][2];
		int y2 = lines[i][3];

		if (y1 < y2) {
			highestPoint.y += y1;
			highestPoint.x += x1;
			lowestPoint.y += y2;
			lowestPoint.x += x2;
		}
		else {
			highestPoint.y += y2;
			highestPoint.x += x2;
			lowestPoint.y += y1;
			lowestPoint.x += x1;
		}


		Point a(x1, y1);
		Point b(x2, y2);
		double res = norm(a - b);
		longestLine = res;
		//line(frame, Point(x1, y1),
		//Point(x2, y2), Scalar(0, 0, 255), 3, 8);
		//circle(frame, Point(x1, y1), 5, (0, 0, 255), -1);
		//circle(frame, Point(x2, y2), 5, (0, 255, 0), -1);
		float angle = atan2(y1 - y2, x1 - x2);
		//cout << "angle = " << angle << endl;
		if (x2 - x1 != 0) {
			int slope = (y2 - y1) / (x2 - x1);
			//cout << "Slope = " << slope << endl;
		}

		//line(frame, Point(bestFitLine[0], bestFitLine[1]),
		//	Point(bestFitLine[2], bestFitLine[3]), Scalar(0, 0, 255), 3, 8);
		//circle(frame, Point(x1, y1), 5, (0, 0, 255), -1);
		//circle(frame, Point(x2, y2), 5, (255, 0, 0), -1);

	}

	if (numLines > 0) {
		highestPoint.y /= numLines;
		highestPoint.x /= numLines;
		lowestPoint.y /= numLines;
		lowestPoint.x /= numLines;
		line(input, highestPoint,
			lowestPoint, Scalar(0, 0, 255), 3, 8);
		topAvg.x += highestPoint.x;
		topAvg.y += highestPoint.y;
		botAvg.x += lowestPoint.x;
		botAvg.y += lowestPoint.y;
		// Every 5 frames add to the average line
		if (processCount % 5 == 0) {
			numAvgLines++;
			topAvg.x /= 5;
			topAvg.y /= 5;
			botAvg.x /= 5;
			botAvg.y /= 5;
			topTemp = topAvg;
			botTemp = botAvg;
			topAvg.x = 0;
			topAvg.y = 0;
			botAvg.x = 0;
			botAvg.y = 0;

		}


		circle(input, topAvg, 5, (255, 255, 255), -1);

		if ((botTemp.x != 0) && (botTemp.y != 0)) {

			line(input, topTemp,
				botTemp, Scalar(0, 255, 0), 3, 8);
			int midX = (botTemp.x + topTemp.x) / 2;
			int midY = (botTemp.y + topTemp.y) / 2;
			circle(input, Point(midX, midY), 5, (0, 0, 0), -1);
			int shiftAmount = getShiftAmount(midX);
			int mid = (topTemp.x + shiftAmount + botTemp.x + shiftAmount) / 2;

			Point topTrans(topTemp.x + shiftAmount, topTemp.y);
			Point botTrans(botTemp.x + shiftAmount, botTemp.y);

			// Each line here is drawn and forms a triangle which we use to calculate the angel we need
			// to turn to stay on the line

			// Draws the shifted line onto the middle of the image
			line(input, botTrans,
				topTrans, Scalar(255, 255, 0), 3, 8);

			// Draws the line from the middle point of the average line found
			// and draws from its middle point to the center of the image
			line(input, Point(midX, midY),
				Point(320, midY), Scalar(255, 255, 0), 3, 8);

			int diff = 320 - midX;
			cout << "diff = " << diff << endl;
			cout << "midX = " << midX << endl;
			// Draws line from top of transposed line to the middle of image
			line(input, topTrans,
				Point(320, topTrans.y), Scalar(255, 255, 0), 3, 8);


			//float angle2 = atan2(p1.y - p2.y, p1.x - p2.x);
			//float angle2 = atan2(midY - topTemp.y, 320 - topTemp.x);
			//cout << "angle2 = " << angle2 * 180 / CV_PI << endl;
			//float angle = angleBetween(Point(320, midY), Point(topTemp.x + shiftAmount, topTemp.y));
			//circle(frame, Point(320, topAvg.y), 10, (127, 127, 127), -1);
			circle(input, Point(topTemp.x + shiftAmount, topTemp.y), 5, (255, 255, 127), -1);
			//cout << "angle = " << angle << endl;
			double opposite = getLength(topTrans, Point(320, topTrans.y));
			cout << "opposite = " << opposite << endl;
			double hypotenuse = getLength(topTrans, Point(320, midY));
			circle(input, Point(320, midY), 5, (255, 255, 127), -1);
			cout << "hypotenuse = " << hypotenuse << endl;
			cout << "O/H = " << opposite / hypotenuse << endl;
			double testAngle = asin(opposite / hypotenuse) * 180 / CV_PI;
			cout << "testAngle = " << testAngle << endl;

			double degrees = DEG_PER_PIXEL * (midX - 320);
			cout << "degrees = " << degrees << endl;
			getTurningAngle(midX, testAngle, topTemp, botTemp);
			waitKey(0);
		}
	}




	//imshow("canny_output", canny_output);
	//imshow("yellowOnly", yellowOnly);
	imshow("input", input);




}

void sendToArduino(float dist, float deg) {
	int i_deg = (int)deg + 10;
	if (i_deg < 0) i_deg = 0;
	string send_str = to_string((int)dist) + "," + to_string(i_deg) + "\n";
	RS232_cputs(cport_nr, send_str.c_str());
	cout << "Sent to Arduino: " << send_str;
	usleep(8000);
}

void receiveFromArduino() {
	unsigned char str_recv[BUF_SIZE]; // recv data buffer
	int n = RS232_PollComport(cport_nr, str_recv, (int)BUF_SIZE);
	if (n > 0) {
		str_recv[n] = 0;   // put null at end
		cout << "Received " << n << " bytes: " << (char *)str_recv << "\n";
	}
}
