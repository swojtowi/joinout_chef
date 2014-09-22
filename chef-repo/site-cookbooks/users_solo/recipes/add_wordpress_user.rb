users_solo_manage "apache" do
  group_id 48
  action [ :remove, :create ]
end

#kopiowanie pliku
execute "copy wpn_config.php" do
	command "cp /var/www/wordpress/wp-config.php /home/wordpressuser/"
end
