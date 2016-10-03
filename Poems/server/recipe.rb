package 'apache2'
package 'libapache2-mod-php'

directory "/srv/poem"
remote_directory "/srv/poem" do
  action :create
  source './Poems'
  owner 'www-data'
  group 'www-data'
end

execute 'chown -R www-data: /srv/poem'

remote_file '/etc/apache2/sites-available/000-default.conf' do
  source '000-default.conf'
  owner 'root'
  group 'root'
  mode '0644'
end
remote_file '/etc/apache2/htpasswd' do
  source 'htpasswd'
  owner 'root'
  group 'root'
  mode '644'
end


execute 'a2enmod rewrite; a2enmod php; service apache2 restart'
