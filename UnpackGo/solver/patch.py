import struct

d = open('UnpackGo_unpacked.exe').read()
pd = d[:0x7c0]
pd += '\x90' * 5
pd += d[0x7c5:0x7e3]
pd += '\x90' * 4
pd += d[0x7e7:0x431b10]
pd += struct.pack('<d', 3.141592653589793 * 2)
pd += d[0x431b18:]
open('UnpackGo_patched.exe', 'wb').write(pd)
