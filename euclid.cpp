/*
 * euclid.cpp
 *
 *  Created on: Apr 17, 2016
 *      Author: Conor
 *      Description:
 *      Uses the Euclidean Algorithm to sort through a set number of numbers starting at 8
 *      to find the greatest common divisor, the greatest number of modulus operations to get to 0,
 *      and the time it takes for each iteration of i.
 */

#include <iostream>
#include <math.h>
#include <sys/time.h>

using namespace std;
//Variables saved for printing out later
int a = 0;
int highestCost = 0;
int currentGcd = 1;
int gcdMostOps = 1;
//Helper method for, returns the amount of modulus operations and finds sets gcd
int getTotalCost(int a, int b) {
	if (a == 0) {
		return b;
	} else if (b == 0) { // if b is 0 we have finished modding
		currentGcd = a;  //set the current gcd to be tested
		return 0;
	}
	int r = a % b; // get remainder to compute
	a = b;
	b = r;

	return 1 + getTotalCost(a, b);
}
// Sets (a) when it is at the highest modulus operation and calls a helper method for the amount of modulus operations
int totalCost(int n) {
	int currentCost = 0;
	for (int i = 1; i <= n; i++) {
		currentCost = getTotalCost(n, i);
		if (currentCost > highestCost) {  //Checks if current cost is higher than the highest found so far, if so set it the gcd and highest cost
			highestCost = currentCost;
			gcdMostOps = currentGcd;
			a = i;
		}
	}
	return highestCost;
}

int main() {
	int b = 0;
	int n = 0;
	int highestCost = 0;
	cout << "Enter n ";
	cin >> n;

	for (int i = 8; i <= n; i++) { // Start at 8 till n, start timing each iteration right after this loop begins
		struct timeval startVal;
		gettimeofday(&startVal, NULL);
		int cost = totalCost(i);
		if (cost > highestCost) { // check the current cost with highest
			highestCost = cost;   //if cost is greater than highestCost then = highestCost to cost
			b = i;                //set your b value for printing
		}
		struct timeval endVal; //struct for finding the end time
		gettimeofday(&endVal, NULL);
		cout << "At i = " << i << "; gcd (" << a << ", " << b << ")= " << gcdMostOps
				<< " took " << highestCost << " modulus operations "
				<< "time = " << ((double)((endVal.tv_usec - startVal.tv_usec) / 1000.00)) << "ms" << endl;
	}

}
