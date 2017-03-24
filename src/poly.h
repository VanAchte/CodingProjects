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
#ifndef POLY_H_
#define POLY_H_
#include <iostream>
using namespace std;

class Poly {
	friend istream &operator>>(istream &in, Poly &rhs);
	friend ostream &operator<<(ostream &out, const Poly &rhs);
public:
	Poly(int coef, int exp);
	Poly(int coef);
	Poly(const Poly &copy);
	Poly();
//Destructor
	~Poly();

// Arithmetic binary operators
	Poly operator+(const Poly &rhs) const;
	Poly operator+(const int &add) const;
	Poly operator-(const int &sub)const;
	Poly operator-(const Poly &rhs) const;
	Poly operator*(const Poly &rhs) const;

// Assignment operators
	Poly &operator=(const Poly &rhs);
	Poly &operator-=(const Poly &rhs);
	Poly &operator+=(const Poly &rhs);
	Poly operator*=(const Poly& rhs);

// Logical binary operatos
	  bool operator==( const Poly & rhs ) const;
	  bool operator!=( const Poly & rhs ) const;
	  //Setters and getters
	  void setCoeff(int coeff, int expo);
	  int getCoeff(int power);
	  // Equal array values to 0
	  void emptyArray();

private:
	int *polyArray;
	int size;
};

#endif /* POLY_H_ */
