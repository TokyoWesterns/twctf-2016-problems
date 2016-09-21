sed 's/TWC/UPX/g' UnpackGo.exe > tmp_exe; mv tmp_exe UnpackGo.exe
upx -d UnpackGo.exe
python unpack.py
python patch.py
