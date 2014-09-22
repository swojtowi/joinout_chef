execute "configure_wordpress_message" do
	command "echo 'Configure CMS recipe - hello world!'; touch '/tmp/configure_cms'"
end

# execute "create_wordpress_user" do
	# command "sudo adduser wordpressuser"
	# command "sudo passwd wordpressuser"
# end

# include_recipe "users"
# include_recipe "users::sysadmins"
include_recipe "users_solo::add_wordpress_user"

# users_solo_manage "apache1" do
# 	data_bag "wordpress"
# 	group_id 49
# 	action [:remove, :create]
#   end
