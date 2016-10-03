n, e = read_publickey(ARGV[0])
print "Message m: "
STDOUT.flush
m = STDIN.gets.to_i
c = encrypt(m, e, n)
puts "Encrypted: #{c}"
STDOUT.flush
