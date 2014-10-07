name "peerjsserver"
description "The role installing and configuring PeerJSserver"
run_list "recipe[peerjs]"
#run_list "recipe[peerjs::install_peerjs]", "recipe[peerjs::configure_peerjs]"
# env_run_lists "prod" => ["recipe[apache2]"], "staging" => ["recipe[apache2::staging]"], "_default" => []
# default_attributes "apache2" => { "listen_ports" => [ "80", "443" ] }
# override_attributes "apache2" => { "max_children" => "50" }