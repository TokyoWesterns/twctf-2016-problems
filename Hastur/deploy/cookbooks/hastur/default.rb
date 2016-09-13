# put flag1, flag2
remote_file '/flag1' do
  action :create
  owner "root"
  group "root"
  mode "644"
end
remote_file '/flag2' do
  action :create
  owner "root"
  group "root"
  mode "600"
end

# mod_flag
remote_file "/usr/lib/apache2/modules/mod_flag.so" do
  action :create
  owner "root"
  group "root"
  mode "644"
end
remote_file '/etc/apache2/mods-available/flag.load' do
  action :create
  owner "root"
  group "root"
  mode "644"
end
local_ruby_block "Enable configurations" do
  block do |content|
    run_command 'a2enmod flag'
  end
end

# php module
remote_file '/usr/lib/php5/20121212+lfs/hastur.so' do
  action :create
  owner "root"
  group "root"
  mode "644"
end
remote_file '/etc/php5/apache2/conf.d/25-hastur.ini' do
  action :create
  owner "root"
  group "root"
  mode "644"
end

# remove default top page
file '/var/www/html/index.html' do
  action :delete
end

# put pages
%W(
/var/www/html/index.php
/var/www/html/phpinfo.php
).each do |file|
  remote_file file do
    action :create
    user "root"
    group "root"
    mode "644"
  end
end

service 'apache2' do
  action :restart
end

