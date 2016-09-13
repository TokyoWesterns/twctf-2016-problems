package "python-crypto"

user "neo-saitama" do
  home "/home/neo-saitama"
  system_user false
end
group "neo-saitama"

directory "/home/neo-saitama" do
  owner "neo-saitama"
  group "neo-saitama"
  action :create
  mode "0700"
end

remote_file "/etc/xinetd.d/neo-saitama" do
  owner "root"
  group "root"
end

%W(
/home/neo-saitama/alice.py
/home/neo-saitama/bob.py
/home/neo-saitama/carol.py
/home/neo-saitama/crypto.py
/home/neo-saitama/flag
/home/neo-saitama/packet.py
/home/neo-saitama/pk-alice.pem
/home/neo-saitama/pk-bob.pem
/home/neo-saitama/pk-carol.pem
/home/neo-saitama/protocol.py
/home/neo-saitama/router.py
/home/neo-saitama/sk-alice.pem
/home/neo-saitama/sk-bob.pem
/home/neo-saitama/sk-carol.pem
).each do |file|
  remote_file file do
    owner "neo-saitama"
    group "neo-saitama"
    action :create
  end
end

%W(
/home/neo-saitama/alice.sh
/home/neo-saitama/bob.sh
/home/neo-saitama/carol.sh
).each do |file|
  remote_file file do
    owner "neo-saitama"
    group "neo-saitama"
    action :create
    mode "0755"
  end
end

service "xinetd" do
  action :reload
end
