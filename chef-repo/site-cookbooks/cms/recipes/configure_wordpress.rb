execute "configure_wordpress_message" do
	command "echo 'Configure CMS recipe - hello world!'; touch '/tmp/configure_cms'"
end

# execute "create_wordpress_user" do
	# command "sudo adduser wordpressuser"
	# command "sudo passwd wordpressuser"
# end
