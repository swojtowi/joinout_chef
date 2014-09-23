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
package "git"
execute "git clone https://github.com/peers/peerjs-server.git"
nodejs_npm "peer" # /peerjs-server
nodejs_npm "forever" #-g
execute "forever start -l forever.log -o out.log -e err.log /usr/local/bin/peerjs --port 9000"