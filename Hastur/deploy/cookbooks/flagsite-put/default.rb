# put pages
%W(
/var/www/html/flag1
/var/www/html/flag2
/var/www/html/flag3
/var/www/html/.htaccess
).each do |file|
  remote_file file do
    action :create
    user "root"
    group "root"
    mode "644"
  end
end

file '/etc/apache2/apache2.conf' do
  action :edit
  block do |content|
    content.gsub!(%r|(<Directory /var/www/>[^<]*?AllowOverride) None|, '\1 All')
  end
end

local_ruby_block "Enable configurations" do
  block do |content|
    run_command 'a2enmod rewrite'
  end
end

service 'apache2' do
  action :restart
end
