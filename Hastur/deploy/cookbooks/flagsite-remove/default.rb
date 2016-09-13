
# put pages
%W(
/var/www/html/flag1
/var/www/html/flag2
/var/www/html/flag3
/var/www/html/.htaccess
).each do |file|
  file file do
    action :delete
    user "root"
  end
end

file '/etc/apache2/apache2.conf' do
  action :edit
  block do |content|
    content.gsub!(%r|(<Directory /var/www/>[^<]*?AllowOverride) All|, '\1 None')
  end
end

local_ruby_block "Disable configurations" do
  block do |content|
    run_command 'a2dismod rewrite'
  end
end

service 'apache2' do
  action :restart
end
