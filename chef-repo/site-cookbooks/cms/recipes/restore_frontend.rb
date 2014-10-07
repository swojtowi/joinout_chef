#HELLO WORLD!
execute "restore_frontend_message" do
	command "echo 'Restore frontend recipe - hello world!'"
end

#copy joinout_backup zip file from cookbook_file to home directory of wordpressuser
cookbook_file "#{node['cms']['joinout_backup']['package_name']}" do
	path "/home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['package_name']}"
	action :create_if_missing
end

#create directory for joinout_backup in home directory of wordpressuser
directory "/home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}" do
  owner 'root'
  group 'root'
  mode '755'
  action :create
end

#unpack joinout_backup zip file to created directory for joinout_backup
execute "unpack joinout_wordpress_backup" do
	command "tar xvvzf /home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['package_name']} -C /home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}"
end

#chmod for home directory of wordpressuser
directory "/home/#{node['cms']['wordpressuser']['name']}" do
  mode '755'
  action :create
end

#chown for joinout_backup directory in home directory of wordpressuser
directory "/home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}/*" do
	owner 'apache'
	group 'apache'
	recursive true
	action :create
end

#chmod for directories in joinout_backup directory
execute "chmod for joinout_backup directories" do
	command "find /home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}/. -type d -exec chmod 755 {} \\;"
end

#chmod for files in joinout_backup directory
execute "chmod for joinout_backup files" do
	command "find /home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}/. -type f -exec chmod 644 {} \\;"
end

template "/home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}/manifest.json" do
  source 'manifest.json.erb'
  mode 644
    variables(
      :joinout_url => node['network']['interfaces']['eth1']['addresses'].keys[1]
    )
    backup 0
    action :create
end

template "/home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}/wp-content/fv-flowplayer-custom/style-1.css" do
  source 'style-1.css.erb'
  mode 644
    variables(
      :joinout_url => node['network']['interfaces']['eth1']['addresses'].keys[1]
    )
    backup 0
    action :create
end

template "/home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}/wp-content/uploads/#{node['cms']['joinout_backup']['date']['year']}/#{node['cms']['joinout_backup']['date']['month']}/video-chat.min_.js.orig" do
  source 'video-chat.min_.js.orig.erb'
  mode 644
    variables(
      :joinout_url => node['network']['interfaces']['eth1']['addresses'].keys[1]
    )
    backup 0
    action :create
end

template "/home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}/wp-content/uploads/#{node['cms']['joinout_backup']['date']['year']}/#{node['cms']['joinout_backup']['date']['month']}/video-chat.min_.js" do
  source 'video-chat.min_.js.erb'
  mode 644
    variables(
      :joinout_url => node['network']['interfaces']['eth1']['addresses'].keys[1]
    )
    backup 0
    action :create
end

template "/home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}/wp-content/uploads/#{node['cms']['joinout_backup']['date']['year']}/#{node['cms']['joinout_backup']['date']['month']}/video-chat.js" do
  source 'video-chat.js.erb'
  mode 644
    variables(
      :joinout_url => node['network']['interfaces']['eth1']['addresses'].keys[1]
    )
    backup 0
    action :create
end

#restore database from joinout_backup_zip file
include_recipe "cms::restore_database"