# UnpackGo
## build problem
```
go build -ldflags="-w -H windowsgui" UnpackGo.go
```

## build packer
```
cd ./upx-3.91-src/
make all
```

## pack problem
```
sed 's/Shiny Window/UnpackGoGoGo/g' UnpackGo.exe > tmp_exe; mv tmp_exe UnpackGo.exe
./upx-3.91-src/src/upx.out -9 UnpackGo.exe
sed 's/UPX/TWC/g' UnpackGo.exe > tmp_exe; mv tmp_exe UnpackGo.exe
```

## make zip
```
7z a unpack_go.7z UnpackGo.exe
```

## solve
```
sh solve.sh
# execute UnpackGo_patched.exe and move mouse cursor
```

# references

## packer
https://dl.packetstormsecurity.net/papers/general/Using_UPX_as_a_security_packer.pdf

## flag iamge
http://aomoriringo.hateblo.jp/entry/2013/11/30/074758
https://gist.github.com/aomoriringo/7706985
