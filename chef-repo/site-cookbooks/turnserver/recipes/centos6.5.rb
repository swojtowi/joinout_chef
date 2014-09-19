

remote_file "#{Chef::Config[:file_cache_path]}epel-release-6-8.noarch.rpm" do
    source "http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm"
    action :create
end

rpm_package "epel" do
    source "#{Chef::Config[:file_cache_path]}epel-release-6-8.noarch.rpm"
    options"-vh --force"  # options "-ivh --force"
    action :install
end

remote_file "rpmforge-release-0.5.2-2.el4.rf.x86_64.rpm" do
	source "http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el4.rf.x86_64.rpm"
	action :create
end

# Action uprgrade in not working correctly 
#
#rpm_package  "rpmforge" do
#	source "rpmforge-release-0.5.2-2.el4.rf.x86_64.rpm"
#	options "-vh"
#	action :upgrade
#end

#uncomment
#
#execute "rpm -Uvh rpmforge-release-0.5.2-2.el4.rf.x86_64.rpm" do
#	action :run
#end


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

node['centos6.5']['rpm'].each do |name|
 cookbook_file name do
 	path "#{name}" #"#{Chef::Config[:file_cache_path]}#{name}"
 	action :create
 end
 package name do
   source "#{name}"	#	"#{Chef::Config[:file_cache_path]}/#{name}"
   options "-vh --force"
   action :install
 end
end
#cookbook_file "script.sh" do
#  	path  "script.sh" # "#{Chef::Config[:file_cache_path]}script.sh"
#  	action :create
#end



#
# Load firewall rules we know works
#
template "/etc/sysconfig/iptables" do
  source "iptables.erb"
  owner "root"
  group "root"
  mode 00600
  # notifies :restart, resources(:service => "iptables")
end

execute "service iptables restart" do
  user "root" 
  command "service iptables restart"
end
package "mysql-server" do
      options "-y"	
      action :install
end
execute "service mysqld start" do
  user "root" 
  command "service mysqld start"
end
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
# uncomment
#execute "mysql -u root  < /root/createTurnUser.sql" do #execute "mysql -u root -p < /root/createTurnUser.sql" do   bash
#   action :run
#end

execute "rm -f /root/createTurnUser.sql" do
   action :run
end

#node['centos6.5']['rpm'].each do |name|
#	execute "rm -f #{name}" do
#	   	action :run
#	end
#end

# uncomment
# size of varchars in schema.sql was minimalised to 512 to 100 
#execute "mysql -u turn -pturn turn< /root/schema.sql" do #bash
#   action :run
#end

node['centos6.5']['mysql']['addUsers']['longTerm'].each do |name|
  execute name do
	action :run 
  end
end
template "/etc/turnserver/turnserver.conf" do
  source "turnserver.conf.erb"
  owner "root"
  group "root"
  #mode 00600
  # notifies :restart, resources(:service => "iptables")
end

execute "turnserver -o -v" do
	action :run 
end

