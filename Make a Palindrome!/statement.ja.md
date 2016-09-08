複数の単語が与えられます．単語の順番を並び変えて回文を作ってください．
```
入力のフォーマット: N <Word_1> <Word_2> ... <Word_N>
回答のフォーマット: 並び変えた後の単語を空白区切りで
単語には英数字のみ含まれます．

Example Input: 3 ab cba c
Example Answer: ab c cba
```
問題を解くにはppc1.chal.ctf.westerns.tokyo:31111(TCP)に接続してください．
```
$ nc ppc1.chal.ctf.westerns.tokyo 31111
```
 * 時間制限は3分です．
 * 単語数は最大で10です．
 * テストケースは30個あります．最初の1個を解くことでフラグ1が得られます．30個を解くことでフラグ2が得られます．
 * [attachment:samples.7z] サーバー接続のプログラムの例