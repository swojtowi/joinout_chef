
node['directories']['create'].each do |name|
	execute "mkdir -p #{name}" do
		action :run
	end
end
=begin
remote_file "root/rpmbuild/SOURCES/libevent-2.0.21-stable.tar.gz" do
    source "https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz"
    action :create
end
=end

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

execute "rpm -Uvh rpmforge-release-0.5.2-2.el4.rf.x86_64.rpm" do
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
=begin
remote_file "libevent-2.0.21.src.rpm" do
    #remote_file "root/rpmbuild/SPECS/libevent.spec" do
    #source "https://raw.github.com/crocodilertc/libevent/master/libevent.spec"
    #source "https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz"
    source "ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home%3A/kalyaka/CentOS_CentOS-6/src/libevent2-2.0.21-11.1.src.rpm"
    action :create
end

rpm_package "libevent-2.0.21.src.rpm" do
    options "--force -v"
    source "//libevent-2.0.21-2.el6.x86_64"
end
=end
=begin
execute "tar xvfz libevent-2.0.21-stable.tar.gz" do
    action :run
    
end
#"tar xvfz libevent-2.0.21-stable.tar.gz"

node["libevent"]["download"].each do |name|
    
    execute name do
        action :run
        cwd "/libevent-2.0.21-stable"
    end
end

execute "ln -s /usr/local/libexec/* /usr/bin/" do
end
=end

=begin
execute "rpmbuild -ba root/rpmbuild/SPECS/libevent.spec" do
        action :run
end

node['libevent']['rpm'].each do |name|
	package name do
   		source "#{name}"     #   
   		options "-vh --force"
   		action :install
	end

end
=end
 
node['centos6.5']['rpm'].each do |name|
 cookbook_file name do
    mode "0777"
 	path "#{name}" #"#{Chef::Config[:file_cache_path]}#{name}"
 	action :create
 end
 package name do
   source "#{name}"	#	"#{Chef::Config[:file_cache_path]}/#{name}"
   action :install
 end
end

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

execute "mysql -u root  < /root/createTurnUser.sql" do #execute "mysql -u root -p < /root/createTurnUser.sql" do   bash
   action :run
   #return[0,1]
end

execute "rm -f /root/createTurnUser.sql" do
   action :run
   #return[0,1]
end

#node['centos6.5']['rpm'].each do |name|
#	execute "rm -f #{name}" do
#	   	action :run
#	end
#end

# uncomment
# size of varchars in schema.sql was minimalised to 512 to 100 
execute "mysql -u turn -pturn turn< /root/schema.sql" do #bash
   action :run
   #return [0,1]
end

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

