#include <wmmintrin.h>
#include <signal.h>
#include <emmintrin.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

int backdoor = 0;
const int rcon[11] = {1,2,4,8,16,32,64,128, 0x1b, 0x36};
char key[16];

void handler() {
  puts("Time out");
  exit(-1);
}
// AESを1ブロック暗号化する
void aes_encrypt_block(char plain[16], char c_key[16], char result[16]) {
  __m128i cur, key, temp;
  memcpy(&cur, plain, 16);
  memcpy(&key, c_key, 16);
  cur = _mm_xor_si128(cur, key);
  // RoundFunc
  for(int i = 0; i < 10; i++) {
    temp = _mm_aeskeygenassist_si128(key, 0);
    key = _mm_xor_si128(key, _mm_srli_si128(temp, 12));
    key = _mm_xor_si128(key, _mm_slli_si128(key, 4));
    key = _mm_xor_si128(key, _mm_slli_si128(key, 8));
    temp = _mm_set_epi32(rcon[i], rcon[i], rcon[i], rcon[i]);
    key = _mm_xor_si128(key, temp);
    if(backdoor == 0x13371337 && i >= 2) printf("%02x%02x", *((unsigned char*)&key), *((unsigned char*)&key + 1));
    if(i == 9) {
      cur = _mm_aesenclast_si128(cur, key);
    }else {
      cur = _mm_aesenc_si128(cur, key);
    }
  }
  backdoor = 0;
  memcpy(result, &cur, 16);
}

void encrypt(char *str, int len) {
  // padding
  while(len % 16 != 0) {
    str[len++] = '\0';
  }
  char result[16];
  printf("Encrypted: ");
  for(int i = 0; i < len; i += 16) {
    aes_encrypt_block(str + i, key, result);
    for(int j = 0; j < 16; j++) {
      printf("%02x", (int)(unsigned char)result[j]);
    }
  }
  puts("");
}

void show_flag() {
  FILE* fp = fopen("./flag", "r");
  if(fp == NULL){
    fprintf(stderr, "Failed to open the flag file. Please contact administrator\n");
  }
  char flag[120];
  fgets(flag, 100, fp);
  encrypt(flag, strlen(flag));
  exit(0);
}

int main() {
  char line[120];
  FILE* fp = fopen("/dev/urandom", "r");
  if(fp == NULL){
    fprintf(stderr, "Failed to initialize\n");
    exit(-1);
  }
  if(fread(key, 1, 16, fp) != 16) {
    fprintf(stderr, "Failed to initialize\n");
    exit(-1);
  }
  fclose(fp);

  setbuf(stdout, NULL);
  alarm(30);
  signal(SIGALRM, handler);

  for(int i = 0; i < 30; i++) {
    printf("> ");
    if(fgets(line, 100, stdin) == NULL) exit(0);
    if(strlen(line) > 0 && line[strlen(line) - 1] == '\n') {
      line[strlen(line) - 1] = '\0';
    }
    if(strncmp(line, "encrypt ", 8) == 0) {
      char *target = line + 8;
      encrypt(target, strlen(target));
    }else if(strncmp(line, "exit", 4) == 0) {
      exit(0);
    }else if(strncmp(line, "l34k1nf0 ", 9) == 0) {
      backdoor = atoi(line + 9);
    }else if(strncmp(line, "flag", 4) == 0) {
      puts("OK. I'll give you the flag.");
      show_flag();
    }else{
      puts("command not found");
    }
  }
}
