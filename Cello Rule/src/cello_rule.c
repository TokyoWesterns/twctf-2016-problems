#include <limits.h>
#include "Cello.h"

#define N (sizeof(uint64_t) * CHAR_BIT)
#define B(x) (1ULL << (x))

struct C {
	uint64_t state;
	uint64_t rule;
};

var C = Cello(C);

struct U {
	uint64_t val;
};

var U = Cello(U);

var get_file_data(var args)
{
	var data = new(Array, U);
	var fp = new(File, get(args, $I(0)), $S("rb"));
	uint64_t t;
	uint64_t file_size;

	sseek(fp, 0, SEEK_END);
	file_size = stell(fp);
	sseek(fp, 0, SEEK_SET);
	foreach(i in range($I(file_size / 8))) {
		sread(fp, &t, sizeof(uint64_t));
		push(data, $(U, t));
	}

	sclose(fp);
	return data;
}

var get_seed()
{
	uint64_t t;
	var fp = new(File, $S("/dev/urandom"), $S("rb"));
	sread(fp, &t, sizeof(uint32_t));
	t |= (~t) << 32;
	sclose(fp);
	return new(U, $(U, t));
}

// https://rosettacode.org/wiki/Elementary_cellular_automaton/Random_Number_Generator
var get_next_rand(var args)
{
	uint64_t rand_num;
	struct C* cells = get(args, $I(0));
 
 	rand_num = 0;
	foreach(q in range($I(0), $I(64), $I(-1))) {
		uint64_t st = cells->state;
		rand_num |= (st & 1) << c_int(q);
		cells->state = 0;
		foreach(i in range($I(N))){
			if (cells->rule & B(7 & (st >> (c_int(i) - 1) | st << (N + 1 - c_int(i))))){
				cells->state |= B(c_int(i));
			}
		}
	}

	// printf("%016lx\n", rand_num);

	return new(U, $(U, rand_num));
}

var enc_data(var args)
{
	var data = get(args, $I(0));
	var cells = get(args, $I(1));

	foreach(i in range($I(len(data)))){
		set(data, i, $(U, ((struct U*)get(data, i))->val ^ ((struct U*)call($(Function, get_next_rand), cells))->val));
	}
	return NULL;
}

var save_file(var args)
{
	var data = get(args, $I(0));
	var fname = get(args, $I(1));

	var fp = new(File, fname, $S("wb"));

	foreach(i in range($I(len(data)))){
		swrite(fp, &(((struct U*)get(data, i))->val), sizeof(uint64_t));
	}
	sclose(fp);
	return NULL;
}

int main(int argc, char** argv)
{
	struct U* seed;
	struct U* rand_num;
	// struct U* data;

	if(argc < 2){
		printf("usage: %s file.enc\n", argv[0]);
		exit(1);
	}

	seed = call($(Function, get_seed));
	var cells = new(C, $(C, seed->val, 30));
	// var cells = new(C, $(C, 1, 30));

	var fname = new(String, $S(argv[1]));
	var data = call($(Function, get_file_data), fname);
	
	call($(Function, enc_data), data, cells);

	append(fname, $S(".enc"));
	call($(Function, save_file), data, fname);
	
	return 0;
}



