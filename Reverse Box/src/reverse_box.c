#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define ROTL8(x,shift) ((uint8_t) ((x) << (shift)) | ((x) >> (8 - (shift))))

void
init_table(uint8_t sbox[256])
{
	int t;
	srand(time(NULL));
	do {
		t = rand() & 0xff;
	} while (!t);

	sbox[0] = t;
	/* loop invariant: p * q == 1 in the Galois field */
	uint8_t p = 1, q = 1;
	do {
		/* multiply p by x+1 */
		p = p ^ (p << 1) ^ (p & 0x80 ? 0x1B : 0);
		/* divide q by x+1 */
		q ^= q << 1;
		q ^= q << 2;
		q ^= q << 4;
		q ^= q & 0x80 ? 0x09 : 0;
		/* compute the affine transformation */
		sbox[p] = sbox[0] ^ q ^ ROTL8(q, 1) ^ ROTL8(q, 2) ^ ROTL8(q, 3) ^ ROTL8(q, 4);
	} while (p != 1);
	/* 0 is a special case since it has no inverse */
}

int
main(int argc, char *argv[])
{
	uint8_t sbox[256];
	int i;

	if(argc < 2){
		printf("usage: %s flag\n", argv[0]);
		exit(1);
	}

	init_table(sbox);

	for (i = 0; i < strlen(argv[1]); ++i){
		printf("%02x", sbox[argv[1][i]]);
	}
	putchar('\n');

	return 0;
}

