Collect data from the server:
```
$ ruby solve.rb TARGET_IP PORT
```

Enumerate solution candidates from collected data (to stdout):
```
$ g++ solve.cpp -lgmp -lgmpxx -O3
$ ./solve {N} < data
```

To find a solution quickly, set $k = rand(1 << 1024)$ after `./solve` outputs a few candidates.

