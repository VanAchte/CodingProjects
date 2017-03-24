// ------------------------------------------------ poly.cpp -------------------------------------------------------
//
// Programmer Name: Conor Van Achte CSS343
// September 29, 2016
// Date of Last Modification: October 8, 2016
// --------------------------------------------------------------------------------------------------------------------
// Purpose: Allow creation of a polynomial object, which can be manipulated to add, subtract, multiply,
//          and to compare.
// --------------------------------------------------------------------------------------------------------------------
// Notes: Assumes no negative exponents are entered and correct input is entered.
// --------------------------------------------------------------------------------------------------------------------
#include "poly.h"
#include <iostream>
using namespace std;
// ------------------------------------Poly------------------------------------
// Description: Two Argument Constructor
// Notes: Requires two ints, a coefficient and an exponent(nonnegative).
// ----------------------------------------------------------------------------
Poly::Poly(int coef, int exp) {
	polyArray = new int[exp + 1];
	for (int i = 0; i <= exp; i++) {
		polyArray[i] = 0;
	}
	polyArray[exp] = coef;
	size = exp + 1;
}
// ------------------------------------Poly------------------------------------
// Description: One Argument Constructor
// ----------------------------------------------------------------------------
Poly::Poly(int coef) {
	polyArray = new int[1];
	polyArray[0] = coef;
	size = 1;
}

// ------------------------------------Poly------------------------------------
// Description: Default Constructor
// ----------------------------------------------------------------------------
Poly::Poly() {
	polyArray = new int[1];
	polyArray[0] = 0;
	size = 1;
}
// ------------------------------------Poly------------------------------------
// Description: Destructor
// ----------------------------------------------------------------------------
Poly::~Poly() {
	delete[] polyArray;
}
// ------------------------------------Poly------------------------------------
// Description: Copy Constructor
// ----------------------------------------------------------------------------
Poly::Poly(const Poly &copy) {
	polyArray = new int[1];
	*this = copy;
}
// ------------------------------------operator=------------------------------------
// Description: Overloaded assignment operator. Takes in a Poly and assign the
//              current object to the object passed in.
// ----------------------------------------------------------------------------
Poly &Poly::operator=(const Poly &rhs) {
	if (*this == rhs) {
		return *this;
	}
	size = rhs.size;
	polyArray = new int[size];
	for (int i = 0; i < rhs.size; i++) {
		polyArray[i] = rhs.polyArray[i];
	}
	return *this;
}
// ------------------------------------operator+------------------------------------
// Description:  Overloaded + operator. Adds two Poly objects together
// ----------------------------------------------------------------------------
Poly Poly::operator+(const Poly& rhs) const {
	Poly sum;
	if (size == rhs.size || size > rhs.size) {
		sum = *this;
		for (int i = 0; i < rhs.size; i++) {
			sum.polyArray[i] = polyArray[i] + rhs.polyArray[i];
		}
	} else if (rhs.size > size) {
		sum = rhs;
		for (int i = 0; i < size; i++) {
			sum.polyArray[i] = sum.polyArray[i] + polyArray[i];
		}
	}
	return sum;
}
// ------------------------------------operator+=------------------------------------
// Description: Overloaded += operator, adds and equals the current object to the
//              object being added
// ----------------------------------------------------------------------------
Poly &Poly::operator+=(const Poly &rhs) {
	*this = *this + rhs;
	return *this;
}
// ------------------------------------operator+------------------------------------
// Description:  Overloaded + operator for adding an int
// ----------------------------------------------------------------------------
Poly Poly::operator+(const int &add) const {
	Poly sum = *this;
	sum.polyArray[0] = sum.polyArray[0] + add;
	return sum;
}
// ------------------------------------operator-------------------------------------
// Description: Overloaded - operator, subtracts an int from a Poly object.
// ----------------------------------------------------------------------------
Poly Poly::operator-(const int &sub) const {
	Poly sum = *this;
	sum.polyArray[0] = sum.polyArray[0] - sub;
	return sum;
}
// ------------------------------------operator-------------------------------------
// Description: Overloaded - operator to subtract two Poly objects.
// ----------------------------------------------------------------------------
Poly Poly::operator-(const Poly& rhs) const {
	Poly sum;
	if (size == rhs.size || size > rhs.size) {
		sum = *this;
		for (int i = 0; i < rhs.size; i++) {
			sum.polyArray[i] = polyArray[i] - rhs.polyArray[i];
		}
	} else if (rhs.size > size) {
		sum = rhs;
		for (int i = 0; i < size; i++) {
			sum.polyArray[i] = polyArray[i] - sum.polyArray[i];
		}
		for (int j = size; j < rhs.size; j++) {
			sum.polyArray[j] = 0 - sum.polyArray[j];
		}
	}
	return sum;

}
// ------------------------------------operator-=------------------------------------
// Description: Overloaded -= operator, operates on another Poly object.
// ----------------------------------------------------------------------------
Poly &Poly::operator-=(const Poly &rhs) {
	*this = *this - rhs;
	return *this;
}
// ------------------------------------emptyArray------------------------------------
// Description: Assigns all values in the array to 0.
// ----------------------------------------------------------------------------
void Poly::emptyArray() {
	for (int i = 0; i < size; i++) {
		polyArray[i] = 0;
	}
}
// ------------------------------------operator>>------------------------------------
// Description: Overloaded input operator, reads in a coefficent and an exponent
//
// ----------------------------------------------------------------------------
istream& operator>>(istream &input, Poly &rhs) {
	// Make sure the array being written into is empty.
	rhs.emptyArray();
	int coeff;
	int exp;

	//read the first 2 ints
	input >> coeff;
	input >> exp;

	// continue reading until user enters -1 -1

	// For some unknown reason this doesn't work with coeff != -1 && exp != -1, so
	// since we assume the user will never enter a negative exponent, exit if they enter a -1
	// into the exponent, because we can safely assume they entered a -1 into the coefficient.

	while (exp != -1) {
		rhs.setCoeff(coeff, exp);
		input >> coeff;
		input >> exp;

	}
	return input;
}
// ------------------------------------operator<<------------------------------------
// Description: Overloaded output operator, prints out the polynomial in the form of +5x^7, for example.
// ----------------------------------------------------------------------------
ostream& operator<<(ostream &output, const Poly &r) {
	if (r.size == 1) {
		output << " 0";
	}
	for (int i = r.size - 1; i >= 0; i--) {
		// If the coefficient is 0, do not include it in the string
		if (r.polyArray[i] != 0) {
			output << " ";
			// If the number is positive, include a "+"
			if (r.polyArray[i] > 0) {
				output << "+";
			} else if(r.polyArray[i] == -1) {
				output << "-";
			}
// Add the coefficient to the string
			if (r.polyArray[i] != 1 && r.polyArray[i] != -1) {
				output << r.polyArray[i];
			}
// Check the exponent
			if (i > 0) {
				output << "x";
				if (i > 1) {
					output << "^";
					output << i;
				}
			}
		}
	}
	return output;
}
// ------------------------------------getCoeff------------------------------------
// Description: Returns the coeff at the power/exponent passed in.
// ----------------------------------------------------------------------------
int Poly::getCoeff(int power) {
	if (power < 0 || power > size) {
		return 0;
	}
	return polyArray[power];
}
// ------------------------------------operator*------------------------------------
// Description: Overloaded * operator, allows multiplication between two Poly objects.
// ----------------------------------------------------------------------------
Poly Poly::operator*(const Poly& rhs) const {
	Poly sum(0, size + rhs.size - 1);
	sum.size = size + rhs.size - 1;
	for (int i = 0; i < size; i++) {
		for (int j = 0; j < rhs.size; j++) {
			int coeff = polyArray[i] * rhs.polyArray[j];
			int exp = i + j;
			Poly add(coeff, exp);
			sum += add;
		}
	}
	return sum;
}
// ------------------------------------operator*=------------------------------------
// Description: Overloaded operator*=, multiples two Polys and equals it to a Poly object
// ----------------------------------------------------------------------------
Poly Poly::operator*=(const Poly& rhs) {
	*this = *this * rhs;
	return *this;
}
// ------------------------------------operator==------------------------------------
// Description: Compares two Poly objects to see if they are equal or not.
// ----------------------------------------------------------------------------
bool Poly::operator==(const Poly& r) const {
	if (size != r.size) {
		return false;
	} else {
		for (int i = 0; i < size; i++) {
			if (polyArray[i] != r.polyArray[i]) {
				return false;
			}
		}
	}
	return true;
}
// ------------------------------------operator!=------------------------------------
// Description: Overloaded != operator. Compares two Poly objects
// ----------------------------------------------------------------------------
bool Poly::operator!=(const Poly& r) const {
	return !(*this == r);

}
// ------------------------------------setCoeff------------------------------------
// Description: Takes in a coefficient and an exponent, and sets the coefficient value.
// ----------------------------------------------------------------------------
void Poly::setCoeff(int coeff, int exp) {
	if (exp >= 0 && exp < size) {
		polyArray[exp] = coeff;
	} else {

		int* temp = new int[exp + 1];

		for (int i = 0; i < size; i++) {
			temp[i] = polyArray[i];
		}

		for (int i = size; i < exp + 1; i++) {
			temp[i] = 0;
		}

		temp[exp] = coeff;

		delete[] polyArray;
		polyArray = temp;
		size = exp + 1;
	}
}

