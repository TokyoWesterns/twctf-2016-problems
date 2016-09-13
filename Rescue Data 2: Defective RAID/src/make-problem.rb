require_relative 'raid'
raid = RaidController.new
Dir.mkdir "disks" if not Dir.exist? "disks"
5.times do |i|
  file = "disks/disk#{i}"
  File.binwrite(file, "\0".b * 1024 * 256)
  raid.assign(i, file)
end

wholedisk = "/tmp/nastmp"

File.binwrite(wholedisk, "\0".b * raid.size)
system("mkfs.fat #{wholedisk}")
system("mount #{wholedisk} /mnt")
system("cp storage/dog-1210559_1280.jpg /mnt/")
system("mkdir /mnt/d3flate")
system("cp storage/d3flate/Makefile /mnt/d3flate/")
system("cp storage/d3flate/d3flate.c /mnt/d3flate/")
system("mkdir /mnt/d3flate/exploit")
system("cp storage/d3flate/exploit/exploit.py /mnt/d3flate/exploit/")
system("cp storage/d3flate/d3flate /mnt/d3flate/")
system("cp storage/dog-1194083_1280.jpg /mnt/")
system("umount /mnt")
raid.write(0, File.binread(wholedisk))
