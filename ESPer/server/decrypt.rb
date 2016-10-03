p, q, dp, dq, qinvp = read_privkey(ARGV[0])
print "Encrypted Message c: "
STDOUT.flush
c = STDIN.gets.to_i
m1 = decrypt(c, dp, p)
m2 = decrypt(c, dq, q)
m = merge(m1, m2, p, q, qinvp)
puts "Decrypted: #{m}"
STDOUT.flush
