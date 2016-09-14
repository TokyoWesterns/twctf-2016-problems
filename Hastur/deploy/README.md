Hastur
======

Make pcap
--------
```
cd deploy
vagrant up
itamae ssh --vagrant roles/main.rb
itamae ssh --vagrant cookbooks/flagsite-put/default.rb

vagrant ssh
sudo tcpdump -w tcpdump-src.pcap port 31178 or port 31179
```
```
cd ../src/pcap
sh ./request.sh
```

Test Deployment and Exploitation
--------------------------------
```
cd deploy
vagrant up
itamae ssh --vagrant roles/main.rb

cd ../exploit
python exploit.py
python recover-key.py
```

Deployment
----------
create Ubuntu 14.04 i386 container on server
```
sudo lxc-create -t ubuntu -n hastur -- -a i386 -r trusty
# for port forwarding: https://github.com/patrakov/lxc-expose-port
sudo wget -O /var/lib/lxc/hastur/rootfs/etc/lxc/lxc-expose-port https://raw.githubusercontent.com/patrakov/lxc-expose-port/master/lxc-expose-port
sudo tee -a /var/lib/lxc/hastur/config
lxc.network.script.up = /etc/lxc/lxc-expose-port {sshport}:22 31178-31179:31178-31179
lxc.network.script.down = /etc/lxc/lxc-expose-port
^D
sudo lxc-start -d -n hastur
sudo lxc-console -n hastur
hastur login: ubuntu
chmod 0700 ~
passwd
^Aq
```
```
cd deploy
itamae ssh --host target.server --port {sshport} --user ubuntu roles/main.rb
```

Distribution
------------
distribute following files
* tcpdump.pcap
* hastur.so
* mod_flag.so

