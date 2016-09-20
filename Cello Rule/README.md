# Cello Rule
## setting env
```
wget http://libcello.org/static/libCello-2.0.3.tar.gz
tar xzf libCello-2.0.3.tar.gz
cd libCello-2.0.3
make
sudo make install
```

## build problem
```
gcc -std=gnu99 cello_rule.c -lCello -lm -lpthread -o cello_rule && strip cello_rule
```

## make .enc file
```
./cello_rule flag.png
```

## make zip
```
7z a cello_rule.7z cello_rule flag.png.enc
```

## build solver
```
gcc solve.c -o solve
```

## solve
```
./solve out.bmp | hex | python solve.py
```

# references
## random number generator with cellular automaton of rule 30
https://rosettacode.org/wiki/Elementary_cellular_automaton/Random_Number_Generator
