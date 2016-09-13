package "python3-crypto"

user "pinhole" do
  home "/home/pinhole"
  system_user false
end
group "pinhole"

directory "/home/pinhole" do
  owner "pinhole"
  group "pinhole"
  action :create
  mode "0700"
end

remote_file "/etc/xinetd.d/pinhole" do
  owner "root"
  group "root"
end

%W(
/home/pinhole/server.py
/home/pinhole/secretkey.pem
).each do |file|
  remote_file file do
    owner "pinhole"
    group "pinhole"
    action :create
  end
end

%W(
/home/pinhole/server.sh
).each do |file|
  remote_file file do
    owner "pinhole"
    group "pinhole"
    action :create
    mode "0755"
  end
end

service "xinetd" do
  action :reload
end
