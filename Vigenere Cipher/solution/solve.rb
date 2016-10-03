require 'base64'
require 'set'

CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/'

def unshift(char, key)
  return char.tap{|a| p a} unless CHARS.include?(char)
  return CHARS[(CHARS.index(char) - CHARS.index(key) + CHARS.size) % CHARS.size]
end

def decrypt(str, key)
  str.chars.map.with_index do |c, i|
    unshift(c, key[i % key.size])
  end.join
end

def search(e, key, ascii, ckey = '')
  i = 0
  while i < e.size
    if 4.times.all?{|j|(i + j) % key.size < ckey.size}
      unless ascii.include?(e[i, 4])
        return
      end
    end
    i += 4
  end
  if ckey.size == key.size
    puts "\tCandi: #{ckey}"
    puts Base64.decode64(e)
    return
  end
  key[ckey.size].each do |k|
    i = ckey.size
    ne = e + ''
    while i < e.size
      ne[i] = unshift(ne[i], k)
      i += key.size
    end
    search(ne, key, ascii, ckey + k)
  end
end

ascii = ("\n\t" + [*32..126].pack("C*")).chars
ret = []
ascii.each do |c1|
  ascii.each do |c2|
    ascii.each do |c3|
      ret << Base64.encode64(c1 + c2 + c3).split.join
    end
    ret << Base64.encode64(c1 + c2).split.join
  end
  ret << Base64.encode64(c1).split.join
end
kh = []
4.times do |i|
  kh << ret.map{|a|a[i]}.sort.uniq
end
puts "Start Search"
e = File.read(ARGV[0]).strip
(8..14).each do |k_len|
  puts "Key Length: %d" % k_len
  key = []
  k_len.times do |i|
    j = i
    key_candi = CHARS.chars
    while j < e.size
      unless e[j] == '=' || e[j] == "\n"
        tk = []
        64.times do |k|
          if kh[j % 4].include?(unshift(e[j], CHARS[k]))
            tk <<= CHARS[k]
          end
        end
      end
      key_candi &= tk
      j += k_len
    end
    key << key_candi
  end
  if key.include?([])
    puts "\tFailed"
  else
    p key
    search(e, key, Set.new(ret))
  end
end
