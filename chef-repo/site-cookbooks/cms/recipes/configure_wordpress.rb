#HELLO WORLD!
execute "configure_wordpress_message" do
	command "echo 'Configure CMS recipe - hello world!'"
end

#add user wordpressuser
user "#{node['cms']['wordpressuser']['name']}" do
	password "#{node['cms']['wordpressuser']['password']['hash']}"
	gid "apache"
end

#restore_frontend from joinout_backup zip file
include_recipe "cms::restore_frontend"

#set attribute for apache's DocumentRoot path
node.default['cms']['apache']['docroot_dir'] = "/home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}"

#update apache's config file from template 
template "#{node['apache']['dir']}/sites-available/wordpress.conf" do
 	source 'wordpress.conf.erb'
 	mode 0644
  	variables(
    	:document_root_path          => node['cms']['apache']['docroot_dir']
  	)
  	backup 0
  	action :create
end

#install ftp access
include_recipe "cms::install_ftp"
