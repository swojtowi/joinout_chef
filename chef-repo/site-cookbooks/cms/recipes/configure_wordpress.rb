#HELLO WORLD!
execute "configure_wordpress_message" do
	command "echo 'Configure CMS recipe - hello world!'"
end

#add user wordpressuser
include_recipe "users_solo::add_wordpress_user"

#read wordpressuser's data from data_bag
wordpressUser_bag = data_bag_item("users", "wordpressUser")

#set attribute for wordpressuser_name
node.default['cms']['wordpressuser']['name'] = wordpressUser_bag["id"]

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
