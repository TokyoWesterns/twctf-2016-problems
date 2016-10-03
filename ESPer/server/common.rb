require 'openssl'
def mod_pow(a, n, mod)
	ret = 1
	while n > 0
		ret = (ret * a) % mod if n.odd?
		a = (a * a) % mod
		n >>= 1
	end
	ret
end

def encrypt(a, e, n)
	mod_pow(a, e, n)
end

def decrypt(a, d, n)
	mod_pow(a, d, n)
end

def merge(m1, m2, p, q, qinv)
	h = qinv * (m1 - m2) % p
	h * q + m2
end

def read_publickey(file)
  key = OpenSSL::PKey::RSA.new(File.read(file))
  [key.n.to_i, key.e.to_i]
end

def read_privkey(file)
  key = OpenSSL::PKey::RSA.new(File.read(file))
  [key.p.to_i, key.q.to_i, key.dmp1.to_i, key.dmq1.to_i, key.iqmp.to_i]
end
