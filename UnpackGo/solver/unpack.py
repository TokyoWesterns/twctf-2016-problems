def xor(s, key):
	res = ''
	for c in s:
		res += chr(ord(c) ^ key)
	return res

d = open('UnpackGo.exe').read()
ud = d[:0x600]
ud += xor(d[0x600:0x4c0c7e], 0x4e)
ud += d[0x4c0c7e:0x4c0f48]
ud += xor(d[0x4c0f48:0x4d6400], 0xe1)
ud += d[0x4d6400:0x4d6a00].replace('RRRR', '\x00\x00\x00\x00')
ud += xor(d[0x4d6a00:0x61bc47], 0x7f)
ud += d[0x61bc47:]
open('UnpackGo_unpacked.exe', 'wb').write(ud)
