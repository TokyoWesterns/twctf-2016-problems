#include <iostream>
#include <string.h>
#include <algorithm>
#include <string>
#include <iomanip>
#include <vector>
#include <openssl/aes.h>
#include <wmmintrin.h>
#include <emmintrin.h>

using namespace std;
#define round ROUORUROU3831rjo
int rcon_int[10] = {0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36};
__m128i rcon[10];
// ラウンド数
int round;
// 鍵の未確定部分
vector<int> key_unknown;

// 部分鍵
unsigned char pkey[16];
// 目的とする平文
unsigned char target_plain[17];
// 解読対象の暗号
unsigned char target_enc[16];

void check() {
  __m128i subkey[11];
  __m128i temp, cur;
  memcpy(&subkey[round], pkey, 16);
  // forward round
  for(int i = round; i < 10; i++) {
    cur = subkey[i];
    temp = _mm_aeskeygenassist_si128(cur, 0);
    cur = _mm_xor_si128(cur, _mm_srli_si128(temp, 12));
    cur = _mm_xor_si128(cur, _mm_slli_si128(cur, 4));
    cur = _mm_xor_si128(cur, _mm_slli_si128(cur, 8));
    cur = _mm_xor_si128(cur, rcon[i]);
    subkey[i + 1] = cur;
  }
  // reverse round
  for(int r = round; r > 0; r--) {
    cur = subkey[r];
    cur = _mm_xor_si128(cur, rcon[r - 1]);
    cur = _mm_xor_si128(cur, _mm_slli_si128(cur, 4));
    temp = _mm_aeskeygenassist_si128(cur, 0);
    cur = _mm_xor_si128(cur, _mm_srli_si128(temp, 12));
    subkey[r - 1] = cur;
  }
  for(int r = 1; r <= 9; r++) {
    subkey[r] = _mm_aesimc_si128(subkey[r]);
  }
  // 1round decrypt
  memcpy(&cur, target_enc, 16);
  cur = _mm_xor_si128(cur, subkey[10]);
  for(int r = 9; r > 0 ; r--) {
    cur = _mm_aesdec_si128(cur, subkey[r]);
  }
  cur = _mm_aesdeclast_si128(cur, subkey[0]);
  if(memcmp(&cur, target_plain, 16) == 0) {
    {
      unsigned char key[16];
      memcpy(key, &subkey[0], 16);
      for(int i = 0; i < 16; i++) {
        cout << setw(2) << setfill('0') << hex << (int)key[i];
      }
      cout << endl;
    }
    exit(0);
  }
}

void search(int c) {
  if(c == key_unknown.size()) {
    check();
  }else{
    int cur = key_unknown[c];
    for(int i = 0; i < 256; i++) {
      pkey[cur] = i;
      search(c+1);
    }
  }
}

void search() {
  int cur = key_unknown[0];
  for(int i = 0; i < 256; i++) {
    pkey[cur] = i;
    search(1);
  }
}

int main() {
  string _key;
  string _target_enc;
  cin >> round >> _key >> _target_enc >> target_plain;
  for(int i = 0; i < 16; i++) {
    if(_key[i * 2] == '?') {
      key_unknown.push_back(i);
    }else{
      pkey[i] = std::stoul(_key.substr(i * 2, 2), nullptr, 16);
    }
    target_enc[i] = std::stoul(_target_enc.substr(i* 2,2),nullptr,16);
  }
  for(int i = 0; i < 10; i++) {
    rcon[i] = _mm_set_epi32(rcon_int[i],rcon_int[i],rcon_int[i],rcon_int[i]);
  }
  search();
}
