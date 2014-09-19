# impaq 2014
# author: David Siecinski
#
case node[:platform]
	when "centos","redhat","fedora","suse"
    		include_recipe 'turnserver::centos6.5'
	when "debian","ubuntu"
    		include_recipe 'turnserver::debian64'
end


=begin
if platform?("centos")
  include_recipe 'turnserver::centos6.5'
  #include_recipe 'turnserver::centos7'
end
if platform?("debian" || )
  #include_recipe 'debian32'
  include_recipe 'turnserver::debian64' 
end 

if platform?("fedora")
  include_recipe 'turnserver::fedora'
end
if platform?("debian")
  include_recipe 'debian32'
  #include_recipe 'debian64' 
end 
=end
