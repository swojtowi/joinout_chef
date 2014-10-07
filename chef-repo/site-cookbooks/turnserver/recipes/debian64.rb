package "gdebi-core" do
   action :install
end

cookbook_file node['debian64']['coturn'] do
  path "#{Chef::Config[:file_cache_path]}#{node['debian64']['coturn']}"
  action :create
end
execute "gdebi --non-interactive #{Chef::Config[:file_cache_path]}coturn_4.1.1.1-1_amd64.deb" do
	action :run 
end

package "mysql-server" do
      options "-y"	
      action :install
end

template "/root/root_password.sql" do
  source "root_password.sql.erb"
  owner "root"
  group "root"
end
bash "mysqld_safe --init-file=/root/root_password.sql &" do
   action :run
end

execute "service mysql restart" do
  user "root" 
end

node['debian64']['mysql']['on'].each do |name|
    bash name do
     	action :run 
     end
end
node['debian64']['template']['turnserver'].each do |name|
	template "/root/#{name}" do
		source "#{name}.erb"
  		owner "root"
  		group "root"
 		mode 00600	
	end
end
=begin
template "/root/createTurnUser.sql" do
  source "createTurnUser.sql.erb"
  owner "root"
  group "root"
  mode 00600

end
template "/root/schema.sql" do
  source "schema.sql.erb"
  owner "root"
  group "root"
  mode 00600
  # notifies :restart, resources(:service => "iptables")
end
=end
execute "mysql -u root -p123123 mysql< /root/#{node['debian64']['CreateTurnserver']}" do 
   action :run
end

bash "rm -f /root/#{node['debian64']['CreateTurnserver']}" do 
   action :run
end
# size of varchars in schema.sql was reduced to 512 to 100 
execute "mysql -u turn -pturn turn< /root/#{node['debian64']['schema']}" do
   action :run
end

node['debian64']['mysql']['addUsers']['longTerm'].each do |name|
  execute name do
	action :run 
  end
end
template "/etc/turnserver.conf" do
  source "turnserver.conf.erb"
  owner "root"
  group "root"
  mode 00600
  # notifies :restart, resources(:service => "iptables")
end
execute "turnserver -o -v" do
	action :run 
end
=begin
=end
