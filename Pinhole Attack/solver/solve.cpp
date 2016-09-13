#include <iostream>
#include <cassert>
#include <cstdlib>
#include <vector>
#include <gmpxx.h>
#include <algorithm>
using namespace std;

const int k = 1024;

mpz_class n;
vector<pair<mpz_class, int>> muls;

void dfs(int pos, mpz_class cur) {
  int failed = 0;
  for(size_t i = 0; i < muls.size(); i++) {
    mpz_class number = muls[i].first;
    mpz_class lower = cur;
    mpz_class upper = cur + (mpz_class(1) << pos) - 1;
    if(number * lower / n == number * upper / n) {
      if((number + 1) * lower / n == (number + 1) * upper / n) {
        if((number + 1) * lower / n != number * lower / n + muls[i].second) {
          return;
        }
      }
    }else {
      failed += 1;
      if(failed > 30) break;
    }
  }
  cerr << pos << endl;
  if(pos == 0) {
    cout << cur << endl;
    //exit(0);
  }else{
    for(int i = 0; i < 2; i++) {
      dfs(pos - 1,  cur | (mpz_class(i) << (pos - 1)));
    }
  }
}

int main(int argc, char **argv) {
  n = mpz_class(argv[1]);
  cerr << "Loading..." << endl;
  mpz_class t; int b;
  while(cin >> t >> b) muls.emplace_back(t, b);
  sort(muls.begin(), muls.end());
  cerr << "Start" << endl;
  dfs(k, 0);
  return 1;
}

