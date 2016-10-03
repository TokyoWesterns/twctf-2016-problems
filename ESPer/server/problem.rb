require 'securerandom'
require 'tempfile'
require 'digest/sha1'
require 'shellwords'
require 'openssl'
require_relative 'common'

def proof_of_work
  STDOUT.puts "Proof of work is required"
  number_start = SecureRandom.random_number(2 ** 256)
  number_end = number_start + 2 ** 48
  STDOUT.puts "Please input the number such that hashlib.sha1(str(number)).hexdigest().startswith('00000') == true and #{number_start} <= number <= #{number_end}"
  STDOUT.flush
  number = STDIN.gets.to_i
  if number < number_start || number > number_end
    STDOUT.puts "Error: Invalid number"
    exit -1
  elsif !Digest::SHA1.hexdigest(number.to_s).start_with?('00000')
    STDOUT.puts "Error: \"#{Digest::SHA1.hexdigest(number.to_s)}\".start_with?('000000') => false"
    exit -1
  end
  true
end

def menu
  STDOUT.puts <<EOS

======================== MENU ========================
 1. Encryption
 2. Decryption
 3. About
 4. Exit

EOS
  STDOUT.print "Your choice> "
  STDOUT.flush
end

def show_source(source)
  puts "+---+" + "-" * 73 + "+"
  source.lines.each.with_index(1) do |line, number|
    puts "|%3d| %-72s|" % [number, line.chomp]
  end
  puts "+---+" + "-" * 73 + "+"
  STDOUT.flush
end

def help
  STDOUT.puts <<EOS

============================= About ===============================
You are very good ESPer, so that you can change any local variable
value to 2048 bit random integer.

You should specify the ESP string as the line number and variables'
name to change separated by colon.

For example, if the source code is below and your input is "2:x", 
the line 2 works the same as "x = rand(2 ** 2048); puts x". So the
output is random number.
EOS
  show_source "x = 3\nputs x"
  STDOUT.puts <<EOS

Encryption Source code is here.
EOS
  show_source File.read(File.join(File.dirname(__FILE__), "encrypt.rb"))
  STDOUT.puts <<EOS

Decryption Source code is here
EOS
  show_source File.read(File.join(File.dirname(__FILE__), "decrypt.rb"))
  STDOUT.flush
  STDOUT.puts
end

def parse(esp, lines, var)
  if esp.chomp == ''
    return [nil, nil]
  elsif /^(\d+):([a-z0-9]+)$/ =~ esp.chomp
    line = $1.to_i
    v = $2.to_s
    if line > lines || line < 1
      puts "Invalid line number"
      return [nil,nil]
    elsif var.include?(v)
      return [line, v]
    else
      puts "Invalid variable: #{v}"
      return [nil, nil]
    end
  else
    STDOUT.puts "Invalid format"
    return [nil, nil]
  end
end

def encryption(path)
  variables = %w(n e m c)
  source = File.read(File.join(File.dirname(__FILE__), 'encrypt.rb'))
  STDOUT.print "Your ESP string: "
  STDOUT.flush
  esp = STDIN.gets
  line, var = parse(esp, source.lines.count, variables)
  lines = source.lines
  lines[line - 1] = "#{var} = SecureRandom.random_number(2 ** 2048);" + lines[line - 1] if line
  Tempfile.open("temp-run") do |f|
    f.puts lines.join
    f.flush
    system "/usr/bin/ruby2.0", "-r", "securerandom", "-r", File.join(File.dirname(File.realpath(__FILE__)), 'common.rb'), f.path, path
  end
end

def decryption(path)
  variables = %w(p q dp dq qinvp m1 m2 m c)
  source = File.read(File.join(File.dirname(__FILE__), 'decrypt.rb'))
  STDOUT.print "Your ESP string: "
  STDOUT.flush
  esp = STDIN.gets
  line, var = parse(esp, source.lines.count, variables)
  lines = source.lines
  lines[line - 1] = "#{var} = SecureRandom.random_number(2 ** 2048);" + lines[line - 1] if line
  Tempfile.open("temp-run") do |f|
    f.puts lines.join
    f.flush
    system "/usr/bin/ruby2.0", "-r", "securerandom", "-r", File.join(File.dirname(File.realpath(__FILE__)), 'common.rb'), f.path, path
  end

end
proof_of_work

STDOUT.puts

f = Tempfile.open('privkey')
path = f.path
f.delete
system "openssl genrsa 2048 2>&1 > #{Shellwords.escape(path)}"
rsa = OpenSSL::PKey::RSA.new(File.open(path))

4.times do |i|
  menu
  choice = gets.to_i
  puts ""
  if !(1..4).include?(choice)
    puts "Invalid choice"
  elsif choice == 1
    encryption path
  elsif choice == 2
    decryption path
  elsif choice == 3
    help
  elsif choice == 4
    puts "See you!"
    break
  end
  if i == 4
    puts "See you!"
  end
end
puts ""
STDOUT.flush
sleep 1
puts "The flag(with random padding) is here."
flag = File.read("flag") + "\0"
while flag.length < 100
  flag += SecureRandom.random_number(256).chr
end
puts encrypt(flag.unpack("H*")[0].to_i(16), rsa.e.to_i, rsa.n.to_i)

begin
  File.unlink(path)
rescue
end
f.close!

