#define _USE_MATH_DEFINES

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include <string.h>

#define DCT 0
#define IDCT 1

#pragma pack(1)
typedef struct TagBITMAPFILEHEADER {
	uint16_t bfType;
	uint32_t bfSize;
	uint16_t bfReserved1;
	uint16_t bfReserved2;
	uint32_t  bfOffBits;
} BITMAPFILEHEADER;
#pragma pack()

typedef struct {
	uint32_t biSize;
	uint32_t biWidth;
	uint32_t biHeight;
	uint16_t biPlanes;
	uint16_t biBitCount;
	uint32_t biCompression;
	uint32_t biSizeimage;
	uint32_t biXPixPerMeter;
	uint32_t biYPixPerMeter;
	uint32_t biClrUsed;
	uint32_t biClrImportant;
} BITMAPINFOHEADER;

typedef struct {
	uint8_t blue;
	uint8_t green;
	uint8_t red;
} RGB_DATA;

typedef struct {
	double Y;
	double Cb;
	double Cr;
} YCC_DATA;

// https://github.com/fukuchi/libqrencode/blob/master/rsecc.c
int initialized = 0;

#define SYMBOL_SIZE (8)
#define symbols ((1 << SYMBOL_SIZE) - 1)
const int proot = 0x11d; /* stands for x^8+x^4+x^3+x^2+1 (see pp.37 of JIS X0510:2004) */

/* min/max codeword length of ECC, calculated from the specification. */
#define min_length (2)
#define max_length (255)
#define max_generatorSize (max_length)

unsigned char alpha[symbols + 1];
unsigned char aindex[symbols + 1];
unsigned char generator[max_length - min_length + 1][max_generatorSize + 1];
unsigned char generatorInitialized[max_length - min_length + 1];

void RSECC_initLookupTable(void)
{
    int i, b;

    alpha[symbols] = 0;
    aindex[0] = symbols;

    b = 1;
    for(i = 0; i < symbols; i++) {
        alpha[i] = b;
        aindex[b] = i;
        b <<= 1;
        if(b & (symbols + 1)) {
            b ^= proot;
        }
        b &= symbols;
    }
}

void RSECC_init(void)
{
    RSECC_initLookupTable();
    memset(generatorInitialized, 0, (max_length - min_length + 1));
    initialized = 1;
}

void generator_init(int length)
{
    int i, j;
    int g[max_generatorSize + 1];

    g[0] = 1;
    for(i = 0; i < length; i++) {
        g[i + 1] = 1;
        /* Because g[0] never be zero, skipped some conditional checks. */
        for(j = i; j > 0; j--) {
            g[j] = g[j - 1] ^  alpha[(aindex[g[j]] + i) % symbols];
        }
        g[0] = alpha[(aindex[g[0]] + i) % symbols];
    }

    for(i = 0; i <= length; i++) {
        generator[length - min_length][i] = aindex[g[i]];
    }

    generatorInitialized[length - min_length] = 1;
}

int RSECC_encode(int data_length, int ecc_length, const unsigned char *data, unsigned char *ecc)
{
    int i, j;
    unsigned char feedback;
    unsigned char *gen;

    if(!initialized) {
        RSECC_init();
    }

    if(ecc_length > max_length) return -1;

    memset(ecc, 0, ecc_length);

    if(!generatorInitialized[ecc_length - min_length]) generator_init(ecc_length);

    gen = generator[ecc_length - min_length];

    for(i = 0; i < data_length; i++) {
        feedback = aindex[data[i] ^ ecc[0]];
        if(feedback != symbols) {
            for(j = 1; j < ecc_length; j++) {
                ecc[j] ^= alpha[(feedback + gen[ecc_length - j]) % symbols];
            }
        }
        memmove(&ecc[0], &ecc[1], ecc_length - 1);
        if(feedback != symbols) {
            ecc[ecc_length - 1] = alpha[(feedback + gen[0]) % symbols];
        } else {
            ecc[ecc_length - 1] = 0;
        }
    }

    return 0;
}

//https://github.com/avivrosenberg/dct-carver/blob/3259e5cd20b4c87075f1431a84d7980cf9b4683d/src/fft2d/shrtdct.c
#define C8_1R   0.49039264020161522456
#define C8_1I   0.09754516100806413392
#define C8_2R   0.46193976625564337806
#define C8_2I   0.19134171618254488586
#define C8_3R   0.41573480615127261854
#define C8_3I   0.27778511650980111237
#define C8_4R   0.35355339059327376220
#define W8_4R   0.70710678118654752440


void ddct8x8s(double **a, int height_offset, int width_offset,int mode)
{
    int j;
    double x0r, x0i, x1r, x1i, x2r, x2i, x3r, x3i;
    double xr, xi;
    
    if (mode == DCT) {
        for (j = 0; j <= 7; j++) {
            x0r = a[height_offset + 0][width_offset + j] + a[height_offset + 7][width_offset + j];
            x1r = a[height_offset + 0][width_offset + j] - a[height_offset + 7][width_offset + j];
            x0i = a[height_offset + 2][width_offset + j] + a[height_offset + 5][width_offset + j];
            x1i = a[height_offset + 2][width_offset + j] - a[height_offset + 5][width_offset + j];
            x2r = a[height_offset + 4][width_offset + j] + a[height_offset + 3][width_offset + j];
            x3r = a[height_offset + 4][width_offset + j] - a[height_offset + 3][width_offset + j];
            x2i = a[height_offset + 6][width_offset + j] + a[height_offset + 1][width_offset + j];
            x3i = a[height_offset + 6][width_offset + j] - a[height_offset + 1][width_offset + j];
            xr = x0r + x2r;
            xi = x0i + x2i;
            a[height_offset + 0][width_offset + j] = C8_4R * (xr + xi);
            a[height_offset + 4][width_offset + j] = C8_4R * (xr - xi);
            xr = x0r - x2r;
            xi = x0i - x2i;
            a[height_offset + 2][width_offset + j] = C8_2R * xr - C8_2I * xi;
            a[height_offset + 6][width_offset + j] = C8_2R * xi + C8_2I * xr;
            xr = W8_4R * (x1i - x3i);
            x1i = W8_4R * (x1i + x3i);
            x3i = x1i - x3r;
            x1i += x3r;
            x3r = x1r - xr;
            x1r += xr;
            a[height_offset + 1][width_offset + j] = C8_1R * x1r - C8_1I * x1i;
            a[height_offset + 7][width_offset + j] = C8_1R * x1i + C8_1I * x1r;
            a[height_offset + 3][width_offset + j] = C8_3R * x3r - C8_3I * x3i;
            a[height_offset + 5][width_offset + j] = C8_3R * x3i + C8_3I * x3r;
        }
        for (j = 0; j <= 7; j++) {
            x0r = a[height_offset + j][width_offset + 0] + a[height_offset + j][width_offset + 7];
            x1r = a[height_offset + j][width_offset + 0] - a[height_offset + j][width_offset + 7];
            x0i = a[height_offset + j][width_offset + 2] + a[height_offset + j][width_offset + 5];
            x1i = a[height_offset + j][width_offset + 2] - a[height_offset + j][width_offset + 5];
            x2r = a[height_offset + j][width_offset + 4] + a[height_offset + j][width_offset + 3];
            x3r = a[height_offset + j][width_offset + 4] - a[height_offset + j][width_offset + 3];
            x2i = a[height_offset + j][width_offset + 6] + a[height_offset + j][width_offset + 1];
            x3i = a[height_offset + j][width_offset + 6] - a[height_offset + j][width_offset + 1];
            xr = x0r + x2r;
            xi = x0i + x2i;
            a[height_offset + j][width_offset + 0] = C8_4R * (xr + xi);
            a[height_offset + j][width_offset + 4] = C8_4R * (xr - xi);
            xr = x0r - x2r;
            xi = x0i - x2i;
            a[height_offset + j][width_offset + 2] = C8_2R * xr - C8_2I * xi;
            a[height_offset + j][width_offset + 6] = C8_2R * xi + C8_2I * xr;
            xr = W8_4R * (x1i - x3i);
            x1i = W8_4R * (x1i + x3i);
            x3i = x1i - x3r;
            x1i += x3r;
            x3r = x1r - xr;
            x1r += xr;
            a[height_offset + j][width_offset + 1] = C8_1R * x1r - C8_1I * x1i;
            a[height_offset + j][width_offset + 7] = C8_1R * x1i + C8_1I * x1r;
            a[height_offset + j][width_offset + 3] = C8_3R * x3r - C8_3I * x3i;
            a[height_offset + j][width_offset + 5] = C8_3R * x3i + C8_3I * x3r;
        }
    } else if (mode == IDCT) {
        for (j = 0; j <= 7; j++) {
            x1r = C8_1R * a[height_offset + 1][width_offset + j] + C8_1I * a[height_offset + 7][width_offset + j];
            x1i = C8_1R * a[height_offset + 7][width_offset + j] - C8_1I * a[height_offset + 1][width_offset + j];
            x3r = C8_3R * a[height_offset + 3][width_offset + j] + C8_3I * a[height_offset + 5][width_offset + j];
            x3i = C8_3R * a[height_offset + 5][width_offset + j] - C8_3I * a[height_offset + 3][width_offset + j];
            xr = x1r - x3r;
            xi = x1i + x3i;
            x1r += x3r;
            x3i -= x1i;
            x1i = W8_4R * (xr + xi);
            x3r = W8_4R * (xr - xi);
            xr = C8_2R * a[height_offset + 2][width_offset + j] + C8_2I * a[height_offset + 6][width_offset + j];
            xi = C8_2R * a[height_offset + 6][width_offset + j] - C8_2I * a[height_offset + 2][width_offset + j];
            x0r = C8_4R * (a[height_offset + 0][width_offset + j] + a[height_offset + 4][width_offset + j]);
            x0i = C8_4R * (a[height_offset + 0][width_offset + j] - a[height_offset + 4][width_offset + j]);
            x2r = x0r - xr;
            x2i = x0i - xi;
            x0r += xr;
            x0i += xi;
            a[height_offset + 0][width_offset + j] = x0r + x1r;
            a[height_offset + 7][width_offset + j] = x0r - x1r;
            a[height_offset + 2][width_offset + j] = x0i + x1i;
            a[height_offset + 5][width_offset + j] = x0i - x1i;
            a[height_offset + 4][width_offset + j] = x2r - x3i;
            a[height_offset + 3][width_offset + j] = x2r + x3i;
            a[height_offset + 6][width_offset + j] = x2i - x3r;
            a[height_offset + 1][width_offset + j] = x2i + x3r;
        }
        for (j = 0; j <= 7; j++) {
            x1r = C8_1R * a[height_offset + j][width_offset + 1] + C8_1I * a[height_offset + j][width_offset + 7];
            x1i = C8_1R * a[height_offset + j][width_offset + 7] - C8_1I * a[height_offset + j][width_offset + 1];
            x3r = C8_3R * a[height_offset + j][width_offset + 3] + C8_3I * a[height_offset + j][width_offset + 5];
            x3i = C8_3R * a[height_offset + j][width_offset + 5] - C8_3I * a[height_offset + j][width_offset + 3];
            xr = x1r - x3r;
            xi = x1i + x3i;
            x1r += x3r;
            x3i -= x1i;
            x1i = W8_4R * (xr + xi);
            x3r = W8_4R * (xr - xi);
            xr = C8_2R * a[height_offset + j][width_offset + 2] + C8_2I * a[height_offset + j][width_offset + 6];
            xi = C8_2R * a[height_offset + j][width_offset + 6] - C8_2I * a[height_offset + j][width_offset + 2];
            x0r = C8_4R * (a[height_offset + j][width_offset + 0] + a[height_offset + j][width_offset + 4]);
            x0i = C8_4R * (a[height_offset + j][width_offset + 0] - a[height_offset + j][width_offset + 4]);
            x2r = x0r - xr;
            x2i = x0i - xi;
            x0r += xr;
            x0i += xi;
            a[height_offset + j][width_offset + 0] = x0r + x1r;
            a[height_offset + j][width_offset + 7] = x0r - x1r;
            a[height_offset + j][width_offset + 2] = x0i + x1i;
            a[height_offset + j][width_offset + 5] = x0i - x1i;
            a[height_offset + j][width_offset + 4] = x2r - x3i;
            a[height_offset + j][width_offset + 3] = x2r + x3i;
            a[height_offset + j][width_offset + 6] = x2i - x3r;
            a[height_offset + j][width_offset + 1] = x2i + x3r;
        }
    }
}

void rgb2ycc(YCC_DATA **ycc, RGB_DATA **rgb, int num_row, int num_col) {
	int i, j;
	for (i = 0; i < num_row; i++) {
		for (j = 0; j < num_col; j++) {
			ycc[i][j].Y  = 0.29891 * rgb[i][j].red + 0.58661 * rgb[i][j].green + 0.11448 * rgb[i][j].blue;
			ycc[i][j].Cb = -0.16874 * rgb[i][j].red - 0.33126 * rgb[i][j].green + 0.50000 * rgb[i][j].blue;
			ycc[i][j].Cr = 0.50000 * rgb[i][j].red - 0.41869 * rgb[i][j].green - 0.08131 * rgb[i][j].blue;
		}
	}
}

void ycc2rgb(RGB_DATA **rgb, YCC_DATA **ycc, int num_row, int num_col) {
	int i, j;
	for (i = 0; i < num_row ; i++) {
		for (j = 0; j < num_col; j++) {
			rgb[i][j].red = ycc[i][j].Y + 1.40200 * ycc[i][j].Cr;
			rgb[i][j].green = ycc[i][j].Y - 0.34414 * ycc[i][j].Cb - 0.71414 * ycc[i][j].Cr;
			rgb[i][j].blue = ycc[i][j].Y + 1.77200 * ycc[i][j].Cb;
		}
	}
}

void read_bitmapfileheader(FILE *fp, BITMAPFILEHEADER *bmpFH) {
	fseek(fp, 0, SEEK_SET);
	fread(bmpFH, sizeof(BITMAPFILEHEADER), 1, fp);
}

void read_bitmapinfoheader(FILE *fp, BITMAPINFOHEADER *bmpIH) {
	fseek(fp, 14, SEEK_SET);
	fread(bmpIH, sizeof(BITMAPINFOHEADER), 1, fp);
}

void read_bmpdata(FILE *fp, RGB_DATA **data, BITMAPFILEHEADER *bmpFH, BITMAPINFOHEADER *bmpIH) {
	int i, j;
	fseek(fp, bmpFH->bfOffBits, SEEK_SET);
	for (i = 0; i < bmpIH->biHeight; i++) {
		fread(data[i], sizeof(RGB_DATA), bmpIH->biWidth, fp);
	}
}

void write_bitmapfileheader(FILE *fp, BITMAPFILEHEADER *bmpFH) {
    fseek(fp, 0, SEEK_SET);
    fwrite(bmpFH, sizeof(BITMAPFILEHEADER), 1, fp);
}

void write_bitmapinfoheader(FILE *fp, BITMAPINFOHEADER *bmpIH) {
    fseek(fp, 14, SEEK_SET);
    fwrite(bmpIH, sizeof(BITMAPINFOHEADER), 1, fp);
}

void write_bmpdata(FILE *fp, RGB_DATA **data, BITMAPFILEHEADER *bmpFH, BITMAPINFOHEADER *bmpIH) {
    int i, j;
    fseek(fp, bmpFH->bfOffBits, SEEK_SET);
    for (i = 0; i < bmpIH->biHeight; i++) {
        fwrite(data[i], sizeof(RGB_DATA), bmpIH->biWidth, fp);
    }
}

// void print_mat(double **m, int N, int M)
// {
//    int i, j;
//    for(i =0; i< N; i++){
//     printf("%d", ((int)m[i][0])&1);
//     for(j = 1; j < M; j++){
//        printf("%d", ((int)m[i][j])&1);
//     }
//     puts("");
//    }
//    puts("");
// }


// http://pukulab.blog.fc2.com/blog-entry-28.html
void *calloc_mat(size_t type_size, int num_row, int num_col)
{
    char **a, *b;
    int  t = type_size * num_col, i;

    a = (char**)calloc(num_row, sizeof(char*) + t);
     
    if (a) {
        b = (char*)(a + num_row);
        for (i = 0; i < num_row; i++) {
            a[i] = b;
            b += t;
        }
        return a;
    }

    return NULL;
}

void round_mat(double **ymat, int height_offset, int width_offset)
{
	int y, x;
	for(y = 0; y < 8; y++){
		for (x = 0; x < 8; x++){
			ymat[height_offset + y][width_offset + x] = round(ymat[height_offset + y][width_offset + x]);
		}
	}
}

void embed_8chars(double **ymat, int height_offset, int width_offset, char *message)
{
	int i, j, n = 0, tmp;
	for (i = 0; i < 16; i++){
		for (j = (i < 8) ? 0 : i - 7; j <= i && j < 8; j++){
			if(i & 1){
				tmp = (int)ymat[height_offset + j][width_offset + i - j];
				tmp &= 0xfffffffffffffffd;
				tmp |= ((message[n/8] >> (7 - (n % 8))) & 1) << 1;
				ymat[height_offset + j][width_offset + i - j] = (double)tmp;
				n++;
			} else {
				tmp = (int)ymat[height_offset + i - j][width_offset + j];
				tmp &= 0xfffffffffffffffd;
				tmp |= ((message[n/8] >> (7 - (n % 8))) & 1) << 1;
				ymat[height_offset + i - j][width_offset + j] = (double)tmp;
				n++;
			}
		}
	}
}

void embed_message(double **ymat, int height, int width, char *message)
{
	int i, par_size, message_len;
    uint8_t tmp[256] = {0};
    uint8_t ecc[256] = {0};
    // struct rs_control *rs;

    message_len = strlen(message);
    
	// check message length
	if(message_len > 48){
		puts("message is too long");
		exit(1);
	}
    if((height / 8) * (width / 8) * 8 < 255){
        puts("bitmap is too small");
        exit(1);
    }

    RSECC_encode(message_len, 255 - message_len, message, ecc);
    memcpy(tmp, message, message_len);
    memcpy(&tmp[message_len], ecc, 255 - message_len);

	for (i = 0; i < 256; i += 8) {
		ddct8x8s(ymat, (i / width) * 8, i % width, DCT);
		round_mat(ymat, (i / width) * 8, i % width);
		embed_8chars(ymat, (i / width) * 8, i % width, &tmp[i]);
		ddct8x8s(ymat, (i / width) * 8, i % width, IDCT);
	}
    // fwrite(tmp, sizeof(char), 256, stdout);
}

int main(int argc, char *argv[])
{
	FILE *fp;
	int i, j;

	double **ymat;

	BITMAPFILEHEADER bmpFH;
	BITMAPINFOHEADER bmpIH;
	RGB_DATA **rgb_data;
	YCC_DATA **ycc_data;
  
	if(argc < 4){
        printf("usage: %s input_bitmap output_bitmap message\n", argv[0]);
		exit(1);
	}

	// read image header and pixels

	fp = fopen(argv[1], "rb");
	if (fp == NULL) {
		printf("cannot access %s\n", argv[1]);
		exit(1);
	}

	if(fgetc(fp) != 'B' || fgetc(fp) != 'M'){
		printf("invalid file\n");
		exit(1);
	}
	read_bitmapfileheader(fp, &bmpFH);
	read_bitmapinfoheader(fp, &bmpIH);

	rgb_data = (RGB_DATA**)calloc_mat(sizeof(RGB_DATA), bmpIH.biHeight, bmpIH.biWidth);
	read_bmpdata(fp, rgb_data, &bmpFH, &bmpIH);
	fclose(fp);

	ycc_data = (YCC_DATA**)calloc_mat(sizeof(YCC_DATA), bmpIH.biHeight, bmpIH.biWidth);

	rgb2ycc(ycc_data, rgb_data, bmpIH.biHeight, bmpIH.biWidth);

	ymat = (double **)calloc_mat(sizeof(double), bmpIH.biHeight, bmpIH.biWidth);

	for (i = 0; i < bmpIH.biHeight; i++) {
		for (j = 0; j < bmpIH.biWidth; j++) {
			ymat[i][j] = ycc_data[i][j].Y;
		}
	}

	embed_message(ymat, bmpIH.biHeight, bmpIH.biWidth, argv[3]);

	for (i = 0; i < bmpIH.biHeight; i++) {
		for (j = 0; j < bmpIH.biWidth; j++) {
			ycc_data[i][j].Y = ymat[i][j];
		}
	}

	ycc2rgb(rgb_data, ycc_data, bmpIH.biHeight, bmpIH.biWidth);

    fp = fopen(argv[2], "wb");
    if (fp == NULL) {
        printf("cannot create %s\n", argv[2]);
        exit(1);
    }

    write_bitmapfileheader(fp, &bmpFH);
    write_bitmapinfoheader(fp, &bmpIH);
    write_bmpdata(fp, rgb_data, &bmpFH, &bmpIH);

	free(ymat);
	free(rgb_data);
	free(ycc_data);

	return 0;
}


