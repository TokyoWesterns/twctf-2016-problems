class RaidController
  BLOCK_SIZE = 512
  NDISKS = 5

  def initialize(host = "localhost", port = 31337)
    @device = [nil] * NDISKS
    @disksize = nil
  end
  def assign(slot, device)
    @device[slot] = File.open(device, "r+b")
    @disksize ||= @device[slot].size
  end

  def parity1(blocks)
    parity = "".b
    (BLOCK_SIZE/4).times do |i|
      sum = blocks.inject(0) {|sum, block| sum ^ block[i*4,4].unpack("V")[0]}
      parity << [sum].pack("V")
    end
    parity
  end

  def parity2(blocks)
    table = [0, 517762881, 517762881, 593801667]
    parity = "".b
    (BLOCK_SIZE/4).times do |i|
      sum = 0
      blocks.each_with_index do |block, j|
        sum ^= (block[i*4,4].unpack("V")[0] << j)
      end
      sum = (sum & 0xffffffff) ^ table[sum >> 32]
      parity << [sum].pack("V")
    end
    parity
  end

  def data_column(row, lcol)
    n = (NDISKS - 2)
    if row % NDISKS == 4 then
      lcol + 1
    elsif n - lcol <= row % NDISKS then
      lcol + 2
    else
      lcol
    end
  end
  def parity1_column(row)
    -(row + 2) % NDISKS
  end
  def parity2_column(row)
    -(row + 1) % NDISKS
  end

  def read_physical_block(row, pcol)
    @device[pcol].seek(row * BLOCK_SIZE)
    @device[pcol].read(BLOCK_SIZE)
  end
  def write_physical_block(row, pcol, data)
    if row * BLOCK_SIZE + data.length > @disksize then
      raise IOError
    end
    @device[pcol].seek(row * BLOCK_SIZE)
    @device[pcol].write(data)
  end

  def read_block(bindex)
    n = (NDISKS - 2)
    row = bindex / n
    lcol = bindex % n
    pcol = data_column(row, lcol)
    # Our emulator does not support degraded RAID array :-(
    read_physical_block(row, pcol)
  end
  
  def write_block(bindex, data)
    n = (NDISKS - 2)
    row = bindex / n
    lcol = bindex % n

    blocks = n.times.map do |i|
      if i == lcol
        data
      else
        read_physical_block(row, data_column(row, i))
      end
    end

    write_physical_block(row, data_column(row, lcol), data)
    write_physical_block(row, parity1_column(row), parity1(blocks))
    write_physical_block(row, parity2_column(row), parity2(blocks))
  end
  
  def size
    @disksize * (NDISKS-2)
  end
  def read(offset, length)
    return "".b if length == 0
    
    first_block = offset / BLOCK_SIZE
    last_block = (offset + length - 1) / BLOCK_SIZE
    first_start = offset % BLOCK_SIZE
    last_end = (offset + length - 1) % BLOCK_SIZE + 1

    if first_block != last_block then    
      data = read_block(first_block)[first_start..-1]
      (first_block+1 .. last_block-1).each do |block|
        data << read_block(block)
      end
      data << read_block(last_block)[0...last_end]
    else
      data = read_block(first_block)[first_start...last_end]
    end
  end
  def write(offset, data)
    length = data.length
    return if length == 0
    
    first_block = offset / BLOCK_SIZE
    last_block = (offset + length - 1) / BLOCK_SIZE
    first_start = offset % BLOCK_SIZE
    last_end = (offset + length - 1) % BLOCK_SIZE + 1
    origin = BLOCK_SIZE - first_start

    if first_block != last_block then    
      block_data = read_block(first_block)
      block_data[first_start..-1] = data[0...(BLOCK_SIZE - first_start)]
      write_block(first_block, block_data)

      (first_block+1 .. last_block-1).each do |block|
        i = block - first_block - 1
        write_block(block, data[origin + i * BLOCK_SIZE ...
                                origin + (i + 1) * BLOCK_SIZE ])
      end

      block_data = read_block(last_block)
      block_data[0...last_end] = data[-last_end..-1]
      write_block(last_block, block_data)
    else
      block_data = read_block(first_block)
      block_data[first_start...last_end] = data
      write_block(first_block, block_data)
    end
  end
end

if __FILE__ == $0
  raid = RaidController.new
  5.times do |i|
    file = "/tmp/raidtest-disk#{i}"
    File.binwrite(file, "\0".b * 512 * 64)
    raid.assign(i, file)
  end
  
  raid.write(0, "\0".b*raid.size)
  raid.write(0, File.binread("/etc/passwd")*2)
  print raid.read(0, 512*10)
end

