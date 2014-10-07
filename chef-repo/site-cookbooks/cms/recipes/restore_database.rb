#HELLO WORLD!
execute "restore_database_message" do
  command "echo 'Restore database recipe - hello world!'"
end

#set variables from attributes
db_old = node['cms']['wordpress_old']['db']
db_new = node['cms']['wordpress_new']['db']

#define mysql_connection for root
mysql_connection_info = {
   :host     => 'localhost',
   :username => 'root',
   :password => node['mysql']['server_root_password']
}

#drop old mysql_wordpress_user
mysql_database_user db_old['user'] do
  connection    mysql_connection_info
  action        :drop
end

#drop old mysql_wordpress_database
mysql_database db_old['name'] do
  connection  mysql_connection_info
  action      :drop
end

#create new mysql_wordpress_user
mysql_database_user db_new['user'] do
   connection    mysql_connection_info
   password      db_new['pass']
   host          db_new['host']
   database_name db_new['name']
   action        :create
end

#drop and create new mysql_wordpress_database
mysql_database db_new['name'] do
   connection  mysql_connection_info
   action       [ :drop, :create]
end

#grant all privileges on new mysql_wordpress_database for new mysql_wordpress_user
mysql_database_user db_new['user'] do
  connection    mysql_connection_info
  database_name db_new['name']
  privileges    [:all]
  action        :grant
end

template "/home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}/wordpress.sql" do
  source 'wordpress.sql.erb'
  mode 644
    variables(
      :joinout_url => node['network']['interfaces']['eth1']['addresses'].keys[1]
    )
    backup 0
    action :create
end

#restore database from mysql_wordpress_backup placed in joinout_backup's directory
execute "restore database from its backup" do
  command "mysql -u #{node['cms']['wordpress_new']['db']['user']} -p#{node['cms']['wordpress_new']['db']['pass']} #{node['cms']['wordpress_new']['db']['name']} < /home/#{node['cms']['wordpressuser']['name']}/#{node['cms']['joinout_backup']['directory_name']}/wordpress.sql"
end