require_relative 'raidr'
raid = RaidController.new
Dir.mkdir "disks" if not Dir.exist? "disks"
5.times do |i|
  file = "disks/disk#{i}"
  raid.assign(i, file)
end
raid.broken(2, 3)
# File.write("/tmp/recovered", raid.read(0, raid.size))
if raid.read(0, raid.size) =~ /(TWCTF\{.*?\})/ then
  puts $1
end
