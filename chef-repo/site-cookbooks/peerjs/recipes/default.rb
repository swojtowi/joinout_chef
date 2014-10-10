#
# Cookbook Name:: peerjs
# Recipe:: default
#
# Copyright 2014, Impaq
# All rights reserved - Do Not Redistribute
#


#  this cookbook will install a peerjs from git repository and
# run it using forever tool

include_recipe "nodejs::nodejs_from_binary"
package "git"   # git needs libevent 1.4.13-4 while turnserver uses 2.0.21-2
if File.directory?("peerjs-server")==false
    execute "git clone https://github.com/peers/peerjs-server.git"
end
nodejs_npm "peer" # /peerjs-server
nodejs_npm "forever"

execute "ps aux | grep -q '[f]orever'" do
  not_if do
  	 system("rm -f /root/.forever/forever.log")
     system("forever start -l forever.log -o out.log -e err.log  --minUptime 100 #{node['cms']['peerjs']['path']} --port #{node['cms']['peerjs']['port']}") #--minUptime 100
   end
end