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

if system("ps aux | grep  '[f]orever'")==false
    execute "forever start -l forever.log -o out.log -e err.log /usr/local/bin/peerjs --port 9000" do
        #return [0,1]
    end
end