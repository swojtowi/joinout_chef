#
# Cookbook Name:: iptables_menager
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

ports=["tcp --dport 22"]
# ports for peerjs
if File.exist?("/usr/local/lib/node_modules/peer/bin/peerjs")
    ports<<"udp --dport 9000"
    ports<<"tcp --dport 9000"
end

if File.exist?("/usr/bin/turnserver")
    ports.push("udp --dport 3479")

    ports<<"udp --dport 3478"
    ports<<"udp --dport 5766"
    ports<<"udp --dport 58745"
    
    log "adding tcp ports for turnserver"

    ports<<"tcp --dport 5432"
    ports<<"tcp --dport 5766"
    ports<<"tcp --dport 3479"
    ports<<"tcp --dport 3478"
end

if File.directory?("/home/wordpressuser")
    log "adding ports for worpress" do
        level :info
    end

    ports<<"tcp --dport 20"
    ports<<"tcp --dport 21"
    ports<<"tcp --dport 80"
    ports<<"tcp --dport 443"
end

# Allowing tcp

ports.each do |number|
    simple_iptables_rule "INPUT" do
        rule "--proto #{number}"
        jump "ACCEPT"
    end
end

# Rejecting
simple_iptables_rule "INPUT" do
    rule "--ctstate NEW"
    jump "REJECT -m conntrack --ctstate NEW"
    #weight 120
end
