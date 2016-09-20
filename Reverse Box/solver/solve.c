#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define ROTL8(x,shift) ((uint8_t) ((x) << (shift)) | ((x) >> (8 - (shift))))

void
init_table(uint8_t sbox[256], int t)
{
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

int indexof(uint8_t sbox[256], uint8_t enc_c)
{
	int i;
	for (i = 0; i < 0x100; i++){
		if (sbox[i] == enc_c) {
			return i;
		}
	}
	return 0;
}

int
main(int argc, char *argv[])
{
	uint8_t sbox[256];
	uint8_t enc[] = "\x95\xee\xaf\x95\xef\x94\x23\x49\x99\x58\x2f\x72\x2f\x49\x2f\x72\xb1\x9a\x7a\xaf\x72\xe6\xe7\x76\xb5\x7a\xee\x72\x2f\xe7\x7a\xb5\xad\x9a\xae\xb1\x56\x72\x96\x76\xae\x7a\x23\x6d\x99\xb1\xdf\x4a";
	int i, j;

	for (j = 1; j < 0x100; j++) {
		init_table(sbox, j);
		for (i = 0; i < sizeof enc; ++i){
			printf("%02x", indexof(sbox, enc[i]));
		}
		putchar('\n');
	}

	return 0;
}
