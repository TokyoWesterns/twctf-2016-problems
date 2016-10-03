require 'zlib'
png = File.binread('tokyo.png')
out = ''
ofs = 8
out << png[0,ofs]
idat = ''
while true
  type = png[ofs + 4, 4]

  size = png[ofs,4].unpack("N")[0] + 12
  if type == 'IDAT'
    p png[ofs + 4, 4]
    p png[ofs + 8, size - 12]
    idat << png[ofs + 8, size - 12]
  elsif type == 'IEND'
    idat = Zlib.inflate(idat)
    p idat.size
    idat += 'TWCTF{WAMP_Are_You_Ready?}'
    idat = Zlib.deflate(idat)
    out << [idat.size].pack("N")
    out << "IDAT"
    out << idat
    out << [Zlib.crc32(out[-(idat.size + 4)..-1])].pack("N")
    out << png[ofs, size]
    break
  else
    out << png[ofs, size]
  end
  ofs += size
end
File.binwrite('ninth.png', out)
