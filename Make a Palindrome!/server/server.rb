#!/usr/bin/ruby
#
FLAG1 = 'TWCTF{Charisma_School_Captain}'
FLAG2 = 'TWCTF{Hiyokko_Tsuppari}'

def judge(words, input)
  return false if input.join.reverse != input.join
  return false if input.size != words.size
  return words.sort == input.sort
end

def generate_case(case_type = nil, size = 8)
  case_type ||= rand(2)
  case case_type
  when 0
    chars = [*'a'..'z'].shuffle[0,26]
    str = Array.new(rand(10..15)){chars.sample}.join
    str = str + str.reverse[rand(2)..-1]
    ret = []
    while ret.size != size
      strba.insert(rand(str.size), ',')
      ret = str.split(',').select{|a|a.size > 0}
    end
    [ret.shuffle, ret]
  when 1
    chars = [*'a'..'z'].shuffle[0,2]
    str = Array.new(rand(24..30)){chars.sample}.join
    str = str + str.reverse[rand(2)..-1]
    ret = []
    while ret.size != size
      str.insert(rand(str.size), ',')
      ret = str.split(',').select{|a|a.size > 0}
    end
    [ret.shuffle, ret]
  end
end

def send_input(words)
  STDOUT.puts "Input: #{words.size} #{words.join(' ')}"
  STDOUT.flush
end

def get_output
  STDIN.gets.split
end

STDOUT.puts <<EOS
Your task is to make a palindrome string by rearranging and concatenating given words.

Input Format: N <Word_1> <Word_2> ... <Word_N>
Answer Format: Rearranged words separated by space.
Each words contain only lower case alphabet characters.

Example Input: 3 ab cba c
Example Answer: ab c cba


Let's play!

EOS
STDOUT.flush

(1..30).each do |k|
  STDOUT.puts "Case: ##{k}"
  words, answer = generate_case(k == 1 ? 0 : nil, k == 1 ? 5 : k <= 30 ? 10 : 50)
  send_input(words)
  STDOUT.print "Answer: "
  STDOUT.flush
  input = get_output
  STDOUT.print "Judge: "
  if judge(words, input)
    STDOUT.print "Correct! "
    if k == 1
      STDOUT.print FLAG1
    elsif k == 30
      STDOUT.print FLAG2
    end
    STDOUT.puts
  else
    STDOUT.puts "Wrong Answer."
    STDOUT.puts "Sample answer: #{answer.join(' ')}"
    STDOUT.flush
    exit
  end
end
