execute "configure_wordpress_message" do
	command "echo 'Configure CMS recipe - hello world!'; touch '/tmp/configure_cms'"
end

include_recipe "users_solo::add_wordpress_user"

#kopiowanie pliku
execute "copy wpn_config.php" do
	command "cp /var/www/wordpress/wp-config.php /home/wordpressuser/"
end

cookbook_file "#{node['joinout_backup']['package_name']}" do
	path "/home/wordpressuser/#{node['joinout_backup']['package_name']}"
	action :create_if_missing
end

execute "make directory for joinout_backup" do
	command "mkdir /home/wordpressuser/#{node['joinout_backup']['directory_name']}"
	not_if { ::File.directory?("/home/wordpressuser/#{node['joinout_backup']['directory_name']}") }
end

execute "unpack joinout_wordpress_backup" do
	command "tar xvvzf /home/wordpressuser/#{node['joinout_backup']['package_name']} -C /home/wordpressuser/#{node['joinout_backup']['directory_name']}" 
end