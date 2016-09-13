require_relative 'raid5'
raid = Raid5Controller.new
Dir.mkdir "disks" if not Dir.exist? "disks"
Raid5Controller::NDISKS.times do |i|
  file = "disks/disk#{i}"
  File.binwrite(file, "\0".b * 1024 * 512)
  raid.assign(i, file)
end

wholedisk = "/tmp/nastmp"

File.binwrite(wholedisk, "\0".b * raid.size)
system("mkfs.fat #{wholedisk}")
system("mount -o loop #{wholedisk} /mnt")
system("cp -r storage/which-2.21 /mnt/")
system("cp storage/flag.jpg /mnt/")
system("umount /mnt")
raid.write(0, File.binread(wholedisk))
