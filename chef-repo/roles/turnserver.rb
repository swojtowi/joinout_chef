name "turnserver"
description "The role installing and configuring TURNserver"
run_list "recipe[turnserver]"
#run_list "recipe[turn::install_turn]", "recipe[turn::configure_turn]"
# env_run_lists "prod" => ["recipe[apache2]"], "staging" => ["recipe[apache2::staging]"], "_default" => []
# default_attributes "apache2" => { "listen_ports" => [ "80", "443" ] }
# override_attributes "apache2" => { "max_children" => "50" }