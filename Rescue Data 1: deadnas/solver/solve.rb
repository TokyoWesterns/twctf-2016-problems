require_relative 'raid5'
raid = Raid5Controller.new
raid.assign(0, "disks/disk0")
raid.assign(2, "disks/disk2")

wholedisk = "./disk.img"
File.binwrite(wholedisk, raid.read(0, 2 * 1024 * 512))
system("mount -o loop #{wholedisk} /mnt")
system("cp /mnt/flag.jpg ./")
system("umount /mnt")

