#!/usr/bin/env sage
# coding: utf-8

import yaml # if you don't have, run 'sage -pip install pyyaml'
from Crypto.Cipher import AES
from Crypto.Util.number import long_to_bytes

a, b, z, n = yaml.safe_load(open('pubkey'))
enc_key, encrypted_flag = yaml.safe_load(open('encrypted_flag'))

m = matrix(ZZ, len(a) + 1, len(a) + 2)
l = 30 # lambda
for i in xrange(len(a)):
  m[i, i] = 1
  m[i, len(a)] = -l * a[i]
m[len(a), len(a)] = l * enc_key
m[len(a), len(a) + 1] = 1

m = m.LLL()

for row in m:
  if row[-2] == 0 and row[-1] == 1:
    print 'Found key candidate'
    key = sum([x * y for x, y in zip(b, list(row[0:len(a)]))]) % z
    aes = AES.new(long_to_bytes(key).rjust(16, "\0"), AES.MODE_CBC, long_to_bytes(enc_key).rjust(16, "\0")[0:16])
    print repr(encrypted_flag)
    print aes.decrypt(encrypted_flag.encode('latin-1')) # 