execute "install_wordpress_message" do
	# command "echo 'Install CMS recipe - hello world!'; touch '/tmp/install_cms'"
	command "echo 'Install CMS recipe - hello world!' > /tmp/stdout.txt 2> /tmp/stderr.txt"
end