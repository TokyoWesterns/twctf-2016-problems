require 'openssl'
require 'socket'
require 'ctf'
key = OpenSSL::PKey::RSA.new(File.read('./publickey.pem'))
n = key.n.to_i
e = key.e.to_i
c = File.read('./ciphertext').to_i
c = CTF::Math.mod_pow(1, e, n) * c % n
half = n.to_s(2).size / 2

def send(s, val)
  s.puts val.to_s(16)
  s.gets.to_i
end

# returns 0 if m1 = m2 + m
# returns 1 if m1 = m2 + m - n = m2 - (n - m)
# unknown: -1
# fail: nil
# m: m
# mn: m-n
def check(m, nm, c1, c2)
  zero_candi = [(c1 + m) & 3, (c1 + m + 1) & 3]
  one_candi = [(c1 + nm) & 3, (c1 + nm + 1) & 3]
  # p [zero_candi, one_candi]
  if zero_candi.include?(c2) && one_candi.include?(c2)
    return -1
  elsif zero_candi.include?(c2)
    return 0
  elsif one_candi.include?(c2)
    return 1
  else
    return nil
  end
end

def mul(c, k, e, n)
  CTF::Math.mod_pow(k, e, n) * c % n
end
TCPSocket.open(*ARGV) do |s|
  # s.echo = true
  m = send(s, c)
  # m - n 
  fail 'unsolvable' if 0 == (n >> half) & 3
  mn_c = [(m - (n >> half & 3)) % 4]
  mn_c << (mn_c[0] - 1) % 4
  fp = File.open("data", "a")
  r = 0
  4096.times {|k|
    cnt = k
    k = rand(1 << rand(1024))
    k += 1
    m1 = send(s, mul(c, k, e, n))
    m2 = send(s, mul(c, k + 1, e, n))
    d1 = check(m, mn_c[0], m1, m2)
    d2 = check(m, mn_c[1], m1, m2)
    #p [check(m, mn_c[0], m1, m2), check(m, mn_c[1], m1, m2)]
    next if d1 == -1
    next if d1 != d2
    fp.puts "%d %d" % [k, d2]
    r += 1
    STDERR.puts "%d/%d #{Time.now}" % [r, cnt] if r % 100 == 0
    fp.flush
  }
end
