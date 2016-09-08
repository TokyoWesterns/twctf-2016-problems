誰かにディスクを破壊されてしまった！
.bash_historyから下記のコマンドを抽出することはできた．
```
openssl aes-256-cbc -e -in /tmp/flag.jpg -out /mnt/flag:flag -pass file:<(openssl aes-256-cbc -e -in ./key -pass pass:`pwd`/key -nosalt)
```
[attachment:problem.7z] からflagを復元してほしい．

ちなみにntfs.ddは/mntにマウントされていた．

**[2016/09/04 04:12 JST] 問題文に誤りがあったため更新しました．```(-pass pass:`pwd` -> -pass pass:`pwd`/key)```**

ヒント:
 1. $MFTが破壊されています
 2. 暗号化に用いられたkeyファイルは一意に特定することができます