CFLAGS = -fstack-protector -funsigned-char -m32 -O2
LDFLAGS = -m32

all: d3flate
d3flate: d3flate.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< -lz -lcrypto
