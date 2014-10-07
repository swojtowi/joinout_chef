#
# Cookbook Name:: iptables_manager
# Recipe:: default
#
# Copyright 2014, impaq
#
# All rights reserved - Do Not Redistribute
#
 
ports=["tcp --dport 22"]
#peerjs
ports<<"udp --dport 9000"
ports<<"tcp --dport 9000"

#turnserver
ports<<"udp --dport 3479"
ports<<"udp --dport 3478"
ports<<"udp --dport 5766"
ports<<"udp --dport 58745"

ports<<"tcp --dport 5432"
ports<<"tcp --dport 5766"
ports<<"tcp --dport 3479"


#wordpress      
ports<<"tcp --dport 20"
ports<<"tcp --dport 21"
ports<<"tcp --dport 80"
ports<<"tcp --dport 443"

# Allowing 
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
end