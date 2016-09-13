class Raid5Controller
  BLOCK_SIZE = 512
  NDISKS = 3

  def initialize()
    @device = [nil] * NDISKS
    @disksize = nil
  end
  def assign(slot, device)
    if device then
      @device[slot] = File.open(device, "r+b")
      @disksize ||= @device[slot].size
    else
      @device[slot] = nil
    end
  end

  def parity(blocks)
    parity = "".b
    BLOCK_SIZE.times do |i|
      parity << blocks.inject(0) {|sum, block| sum ^ block[i].ord}
    end
    parity
  end

  def data_column(row, lcol)
    n = (NDISKS - 1)
    if n - lcol <= row % NDISKS then
      lcol + 1
    else
      lcol
    end
  end
  def parity_column(row)
    -(row + 1) % NDISKS
  end

  def read_physical_block(row, pcol)
    return unless @device[pcol]
    @device[pcol].seek(row * BLOCK_SIZE)
    @device[pcol].read(BLOCK_SIZE)
  end
  def write_physical_block(row, pcol, data)
    return unless @device[pcol]
    if row * BLOCK_SIZE + data.length > @disksize then
      raise IOError
    end
    @device[pcol].seek(row * BLOCK_SIZE)
    @device[pcol].write(data)
  end

  def read_block(bindex)
    n = (NDISKS - 1)
    row = bindex / n
    lcol = bindex % n
    pcol = data_column(row, lcol)
    if @device[pcol] then
      read_physical_block(row, pcol)
    else
      blocks = NDISKS.times.map do |i|
        if i == pcol then
          "\0".b * BLOCK_SIZE
        else
          read_physical_block(row, i)
        end
      end
      parity(blocks)
    end
  end
  
  def write_block(bindex, data)
    n = (NDISKS - 1)
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
    write_physical_block(row, parity_column(row), parity(blocks))
  end
  
  def size
    @disksize * (NDISKS-1)
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
  raid = Raid5Controller.new
  Raid5Controller::NDISKS.times do |i|
    file = "/tmp/raidtest-disk#{i}"
    File.binwrite(file, "\0".b * 512 * 64)
    raid.assign(i, file)
  end
  
  raid.write(0, "\0".b*raid.size)
  raid.write(0, File.binread("/etc/passwd")*2)
  raid.assign(2, nil)
  print raid.read(0, 512*10)
end

