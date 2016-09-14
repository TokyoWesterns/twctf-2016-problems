Neo Saitama Agency
==================

Test Deployment and Exploitation
--------------------------------
```
cd deploy
vagrant up
itamae ssh --vagrant roles/main.rb

cd ../solver
python solve.py
```

Deployment
----------
```
cd deploy
itamae ssh --host target.server --user tw roles/main.rb
```

