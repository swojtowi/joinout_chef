

remote_file "#{Chef::Config[:file_cache_path]}epel-release-6-8.noarch.rpm" do
    source "http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm"
    action :create_if_missing
    
end

rpm_package "epel" do
    source "#{Chef::Config[:file_cache_path]}epel-release-6-8.noarch.rpm"
    options"-vh --force"  # options "-ivh --force"
    action :install
end

remote_file "/tmp/rpmforge-release-0.5.2-2.el4.rf.x86_64.rpm" do
	source "http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el4.rf.x86_64.rpm"
	action :create_if_missing
end

execute "rpm -Uvh /tmp/rpmforge-release-0.5.2-2.el4.rf.x86_64.rpm" do
	action :run
	returns [0,1]
end

execute "yum --assumeyes --enablerepo rpmforge install dkms " do
    action :run
end

execute "yum --assumeyes --skip-broken groupinstall Development Tools " do
    action :run
end

node['centos6.5']['packages'].each do |name|
    package name do
        action :install
    end
end


#    source "https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz"

cookbook_file "libevent-2.0.21-2.el6.x86_64.rpm" do
    mode "0777"
 	path "/tmp/libevent-2.0.21-2.el6.x86_64.rpm"
 	action :create_if_missing
end
if File.exist?("/usr/lib64/libevent_openssl-2.0.so.5")==false
    execute "rpm -i /tmp/libevent-2.0.21-2.el6.x86_64.rpm" #-vh --force
end


 
node['centos6.5']['turn'].each do |name|
 cookbook_file name do
    mode "0777"
 	path "/tmp/#{name}" #"#{Chef::Config[:file_cache_path]}#{name}"
 	action :create_if_missing
 end
 if File.exist?("/usr/bin/turnserver")==false
     execute "rpm -i /tmp/#{name}"
 end
end

include_recipe "mysql::server"
include_recipe "mysql::client"

execute "service mysqld start"

node['centos6.5']['mysql']['on'].each do |name|
    bash name do
     	action :run 
        #mode '0777'
     end
end
template "/root/createTurnUser.sql" do
  source "createTurnUser.sql.erb"
  owner "root"
  group "root"
  mode 00600
  # notifies :restart, resources(:service => "iptables")
end
template "/root/schema.sql" do
  source "schema.sql.erb"
  owner "root"
  group "root"
  mode 00600
  # notifies :restart, resources(:service => "iptables")
end


userforMysql= "-u root -p#{node['mysql']['server_root_password']}"


execute "mysql #{userforMysql} < /root/createTurnUser.sql" # execute "mysql -u root -p < /root/createTurnUser.sql"

execute "rm -f /root/createTurnUser.sql" 


# size of varchars in schema.sql was minimalised to 512 to 100
if File.directory?("/root/schem_added_sql.lock")==false
    execute "mysql -u turn -pturn turn< /root/schema.sql"
end

directory "/root/schem_added_sql.lock"


node['centos6.5']['mysql']['addUsers']['longTerm'].each do |name|
  execute name
end
template "/etc/turnserver/turnserver.conf" do
  source "turnserver.conf.erb"
end
# run turnserver if returned 1 else do nothing 
execute "ps aux | grep -q '[t]urnserver -o -v'" do
  #returns 0
  not_if do
     system("turnserver -o -v")
   end
end

#execute "rm -f turnserver*.rpm libevent-2.0.21-2.el6.x86_64.rpm rpmforge-release-0.5.2-2.el4.rf.x86_64.rpm"