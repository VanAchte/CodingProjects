#include <iostream>
#include <vector>
#include <math.h>

using namespace std;

int sieve(int n, vector<int> &primes) {

	int cost = 0;
	bool array[n + 1];

// 1. Implement array initialization so that every value is prime except 0 and 1
	for (int p = 0; p < n + 1; p++) {
		array[p] = true;

	}
// 2. Implement Sieve of Eratosthenes algorithm to find prime numbers
// Add cost whenever the array becomes to prime
	for (int i = 2; i <= sqrt(n); i++) {
		if (array[i] == true) {
			for (int j = i * i; j <= n; j += i) {
				array[j] = false;
			}
		}
	}

// 3. Push back the prime numbers into primes (parameter)
	for (int l = 2; l <= n; l++) {
		if (array[l] != 0) {
			primes.push_back(l);
		} else {
			cost++;
		}
	}

	return cost;

}

int main() {

	int n = 0;
	cout << "Enter n ";
	cin >> n;

	char printOption = 'n';
	cout << "print all primes (y|n)? ";
	cin >> printOption;

	for (int i = 2; i <= n; i++) {

		vector<int> primes;
		int cost = sieve(i, primes);

		cout << "primes[1.." << i << "] took " << cost << " sweeping operations" << endl;

		if (printOption == 'y') {
			cout << "all primes = ";
			for (int j = 0; j < (int) primes.size(); j++)
				cout << primes[j] << " ";
			cout << endl;
		}
		cerr << i << " " << cost << endl;
	}

}
