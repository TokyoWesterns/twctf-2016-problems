say "The flag of part 1 is 5 4 5 7 4 3 5 4 4 6 7 b 4 8 3 4" -o part1.aiff -v Samantha
say "The flag of part 2 is 7 6 6 5 5 f 7 9 3 0 7 5 5 f 6 b" -o part2.aiff -v Vicki
say "The flag of part 3 is 6 e 3 0 7 7 6 e 5 f 3 1 4 3 3 4" -o part3.aiff -v Karen
say "The flag of part 4 is 5 f 3 4 6 e 6 4 5 f 4 3 3 0 6 3" -o part4.aiff -v Alex
say "The flag of part 5 is 6 b 7 4 3 4 3 1 6 c 5 f 7 0 3 4" -o part5.aiff -v Daniel
say "The flag of part 6 is 7 2 7 4 7 9 5 f 3 3 6 6 6 6 3 3" -o part6.aiff -v Victoria
say "The flag of part 7 is 6 3 7 4 5 f 7 3 3 1 6 e 6 3 3 3" -o part7.aiff -v Moira
say "The flag of part 8 is 5 f 6 2 3 3 6 6 3 0 7 2 3 3 7 d" -o part8.aiff -v Bruce
say -v Vicki "TWCTF opening brace, ascii string converted from hex numbers, closing brace" -o part9.aiff

for i in `seq 1 9`
do
  ffmpeg -y -i part${i}.aiff part${i}.wav
  rm -f part${i}.aiff
done

python make_whitenoise.py
python mixing_wave.py
