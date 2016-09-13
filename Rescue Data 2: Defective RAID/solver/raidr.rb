def poly_mul(x, y)
  r = 0
  (y.bit_length-1).downto(0) do |i|
    if y & (1 << i) != 0 then
      r ^= x << i
    end
  end
  return r
end
def poly_divmod(x, y)
  q = 0
  r = x
  (x.bit_length-y.bit_length).downto(0) do |i|
    if r & (1 << (i + y.bit_length - 1)) != 0 then
      q |= 1 << i
      r ^= y << i
    end
  end
  return q, r  
end
def poly_div(x, y); poly_divmod(x, y)[0]; end
def poly_mod(x, y); poly_divmod(x, y)[1]; end

def poly_egcd(a, b)
  x0 = 0; x1 = 1
  y0 = 1; y1 = 0
  while b != 0 do
    q, r = poly_divmod(a, b)
    a, b = b, r
    x0, x1 = x1 ^ poly_mul(q, x0), x0
    y0, y1 = y1 ^ poly_mul(q, y0), y0
  end
  return x1, y1, a
end
def polymod_inverse(x, n)
  y, q, d = poly_egcd(x, n)
  if d == 1 then
    return poly_mod(y, n)
  else
    return nil
  end
end
def polymod_div(x, y, n)
  r = poly_mul(x, polymod_inverse(y, n))
  poly_mod(r, n)
end
def polymod_chinese(a, n, b, m)
  x  = poly_mul(a, poly_mul(m, polymod_inverse(m, n)))
  x ^= poly_mul(b, poly_mul(n, polymod_inverse(n, m)))
  return poly_mod(x, poly_mul(n, m))
end

POLY = 0x11EDC6F41
def gf(x)
  poly_mod(x, POLY)
end
def gf_mul(x, y)
  x = gf(x)
  y = gf(y)
  gf(poly_mul(x, y))
end
def gf_inverse(x)
  polymod_inverse(x, POLY)
end
def gf_div(x, y)
  gf_mul(x, gf_inverse(y))
end

def debug(x)
  STDERR.puts(x.inspect)
end

class RaidController
  BLOCK_SIZE = 512
  NDISKS = 5

  def initialize(host = "localhost", port = 31337)
    @device = [nil] * NDISKS
    @disksize = nil
    @broken = []
  end
  def assign(slot, device)
    @device[slot] = File.open(device, "r+b")
    @disksize ||= @device[slot].size
  end
  def broken(d1, d2)
    @broken = [d1, d2]
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
    # table = [0, 0x1EDC6F41, 0x1EDC6F41, 0x1EDC6F41 << 1 ^ 0x1EDC6F41].map{|x|x&0xffffffff}
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
    debug [:read_block, row, lcol, pcol]
    # TODO: remove recovery codes from distribution version
    if @broken.include? pcol then
      p1col = parity1_column(row)
      p2col = parity2_column(row)
      # debug :p1col => parity1_column(row), :p2col => parity2_column(row)

      bs = n.times.map do |i|
        c = data_column(row, i)
        read_physical_block(row, c) unless @broken.include? c
      end

      result = String.new(encoding: "binary")      
      if @broken.include? p2col then
        # when we can use p1
        p1 = read_physical_block(row, p1col)
        (BLOCK_SIZE/4).times do |i|
          x = p1[i*4,4].unpack("V")[0]
          bs.each {|b| x ^= b[i*4,4].unpack("V")[0] if b != nil }
          result << [x].pack("V")
        end
        result
        
      elsif @broken.include? p1col then
        # when we can use p2
        p2 = read_physical_block(row, p2col)
        (BLOCK_SIZE/4).times do |i|
          x = p2[i*4,4].unpack("V")[0]
          bs.each_with_index {|b,j| x ^= b[i*4,4].unpack("V")[0] << j if b != nil }
          result << [gf_div(x, 1 << lcol)].pack("V")
        end
        result
        
      else
        # when 2 data block is broken
        p1 = read_physical_block(row, p1col)
        p2 = read_physical_block(row, p2col)

        # debug [bs, p1, p2]

        vpcol = (@broken - [pcol])[0] # to be vanished
        vlcol = n.times.select{|i| data_column(row, i) == vpcol }[0]
        # debug :vpcol => vpcol, :vlcol => vlcol
        (BLOCK_SIZE/4).times do |i|
          x = (p1[i*4,4].unpack("V")[0] << vlcol) ^ p2[i*4,4].unpack("V")[0]
          bs.each_with_index do |b, j|
            if b != nil then
              x ^= (b[i*4,4].unpack("V")[0] << j) ^ (b[i*4,4].unpack("V")[0] << vlcol)
            end
          end
          x = gf(x)
          # result << [gf_div(x, (1 << lcol) ^ (1 << vlcol))].pack("V")
          x2 = polymod_div(x, (1 << lcol) ^ (1 << vlcol), 4122223935)
          r = 2.times.map {|x1| polymod_chinese(x1, 3, x2, 4122223935) }.sort[0]
          result << [r].pack("V")
        end
      end
      result
    else
      read_physical_block(row, pcol)
    end
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
    debug [:read, first_block, first_start, last_block, last_end]

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
    debug [:write, first_block, first_start, last_block, last_end, origin]

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
  raid.broken(0, 2)
  print raid.read(0, 512*10)
end

