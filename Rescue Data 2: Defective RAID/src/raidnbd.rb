require_relative 'nbd'
require_relative 'raid'

class RaidNBDServer < NBDServer
  BLOCK_SIZE = 512
  NDISKS = 5

  def initialize(host = "localhost", port = 31337)
    @raid = RaidController.new
    super host, port
  end
  def assign(slot, device)
    @raid.assign(slot, device)
  end

  def size
    @raid.size
  end
  def read(offset, length)
    @raid.read(offset, length)
  end
  def write(offset, data)
    @raid.write(offset, data)
  end
end

if __FILE__ == $0
  raid = RaidNBDServer.new
  if ARGV.empty? then
    5.times do |i|
      file = "/tmp/raidtest-disk#{i}"
      File.binwrite(file, "\0".b * 1024 * 256)
      raid.assign(i, file)
    end
  else
    ARGV.each_with_index do |file, i|
      raid.assign(i, file)
    end
  end
  raid.serve
end
