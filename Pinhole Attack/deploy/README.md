Pinhole Attack
=============

Test Deployment and Exploitation
--------------------------------
```
cd deploy
vagrant up
itamae ssh --vagrant roles/main.rb

cd ../solver
# see solver/README.md
```

Deployment
----------
```
cd deploy
itamae ssh --host target.server --user tw roles/main.rb
```

