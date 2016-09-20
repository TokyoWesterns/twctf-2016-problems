from reedsolo import *
rs = RSCodec(255 - 43)
print rs.decode(bytearray(raw_input().strip().decode('hex')))
