#include <stdio.h>
#include <limits.h>
#include <stdint.h>
#include <stdlib.h>

#define N (sizeof(uint64_t) * CHAR_BIT)
#define B(x) (1ULL << (x))

uint64_t file_size;

uint64_t* get_file_data(char* fname)
{
	FILE* fp;
	int i;
	uint64_t* data;

	fp = fopen(fname, "rb");

	if(fp == NULL){
		printf("cannot open %s\n", fname);
		exit(1);
	}

	fseek(fp, 0, SEEK_END);
	file_size = ftell(fp);
	fseek(fp, 0, SEEK_SET);

	data = (uint64_t *)calloc(file_size / 8, sizeof(uint64_t));

	if(data == NULL){
		printf("cannot alloc data\n");
		exit(1);
	}

	fread(data, 1, file_size, fp);
	fclose(fp);

	return data;
}

// https://rosettacode.org/wiki/Elementary_cellular_automaton/Random_Number_Generator
uint64_t get_next_rand(uint64_t* state, int rule)
{
	uint64_t rand_num;
	int i, q;

 	rand_num = 0;
	for(q = 64; q--;) {
		uint64_t st = *state;
		rand_num |= (st & 1) << q;
		*state = 0;
		for(i = 0; i < N; i++){
			if (rule & B(7 & (st >> (i - 1) | st << (N + 1 - i)))){
				*state |= B(i);
			}
		}
	}

	return rand_num;
}

uint64_t bf_state(uint64_t* data)
{
	uint64_t seed;
	uint64_t state;
	for(seed = 0; seed < 0x100000000; seed++){
		state = seed | ((~seed) << 32);
		if((get_next_rand(&state , 30) ^ data[0]) == 0x0a1a0a0d474e5089){
			return seed | ((~seed) << 32);
		}
	}
	return 0;
}

void dec_data(uint64_t* data, uint64_t state)
{
	int i;
	for(i = 0; i < file_size / 8; i++){
		data[i] ^= get_next_rand(&state, 30);
	}
}

void save_file(uint64_t* data, char* fname)
{
	FILE* fp;
	int i;

	fp = fopen(fname, "wb");
	if(fp == NULL){
		printf("cannot open %s\n", fname);
		exit(1);
	}

	fwrite(data, 1, file_size, fp);

	fclose(fp);
}

int main(int argc, char** argv)
{
	uint64_t seed;
	struct U* rand_num;
	uint64_t* data;

	if(argc < 3){
		printf("usage: %s enc_file dec_file\n", argv[0]);
		exit(1);
	}

	data = get_file_data(argv[1]);

	seed = bf_state(data);
	
	dec_data(data, seed);

	save_file(data, argv[2]);
	
	return 0;
}



