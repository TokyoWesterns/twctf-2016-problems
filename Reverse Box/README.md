# Reverse Box

## build problem
```
gcc -m32 -o reverse_box reverse_box.c && strip reverse_box
```

## make zip
```
7z a reverse_box.7z reverse_box
```

## solve
```
gcc solve.c -o solve && ./solve
```

# references
## Rijndael S-box
https://en.wikipedia.org/wiki/Rijndael_S-box

