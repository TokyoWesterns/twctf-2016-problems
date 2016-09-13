package 'apache2'
local_ruby_block "Enable configurations" do
  block do |content|
    run_command 'a2enmod ssl'
    run_command 'a2ensite default-ssl'
  end
end

file '/etc/apache2/mods-available/mpm_prefork.conf' do
  action :edit
  block do |content|
    content.gsub!(/(MaxConnectionsPerChild\s+)0/, '\11')
  end
end

file '/etc/apache2/apache2.conf' do
  action :edit
  block do |content|
    content.gsub!("Options Indexes FollowSymLinks", "Options FollowSymLinks")
  end
end

# Port
file '/etc/apache2/ports.conf' do
  action :edit
  block do |content|
    content.gsub!("80", "31178")
    content.gsub!("443", "31179")
  end
end
file '/etc/apache2/sites-available/000-default.conf' do
  action :edit
  block do |content|
    content.gsub!(":80", ":31178")
  end
end
file '/etc/apache2/sites-available/default-ssl.conf' do
  action :edit
  block do |content|
    content.gsub!(":443", ":31179")
  end
end


# Certificate
remote_file "/etc/ssl/certs/ssl-cert-hastur.pem" do
  owner "root"
  group "root"
  mode "644"
end
remote_file "/etc/ssl/private/ssl-cert-hastur.key" do
  owner "root"
  group "root"
  mode "600"
end

file '/etc/apache2/sites-available/default-ssl.conf' do
  action :edit
  block do |content|
    content.gsub!("ssl-cert-snakeoil", "ssl-cert-hastur")
  end
end

# mod_sandbox
remote_file "/usr/lib/apache2/modules/mod_sandbox.so" do
  action :create
  owner "root"
  group "root"
  mode "644"
end
remote_file '/etc/apache2/mods-available/sandbox.load' do
  action :create
  owner "root"
  group "root"
  mode "644"
end
local_ruby_block "Enable configurations" do
  block do |content|
    run_command 'a2enmod sandbox'
  end
end

service 'apache2' do
  action :restart
end

