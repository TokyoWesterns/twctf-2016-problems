require 'zlib'
png = File.binread('ninth.png')
out = ''
ofs = 8
idat = ''
while true
  type = png[ofs + 4, 4]

  size = png[ofs,4].unpack("N")[0] + 12
  if type == 'IDAT'
    print Zlib.inflate(png[ofs + 8, size - 12])
  elsif type == 'IEND'
    break
  else
  end
  ofs += size
end

