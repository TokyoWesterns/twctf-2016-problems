# Steganographer
## build problem
```
gcc steganographer.c -o steganographer -lm -O2 -w && strip steganographer
```

## make out.bmp
```
./steganographer lena_std.bmp out.bmp TWCTF{DC7_4nd_R5_4r3_v3ry_U53fu1_f0r_57360}
```

## make zip
```
7z a steganographer.7z steganographer out.bmp
```

## build solver
```
gcc solve.c -o solve -lm
```

## solve
```
./solve out.bmp | hex | python solve.py
```
