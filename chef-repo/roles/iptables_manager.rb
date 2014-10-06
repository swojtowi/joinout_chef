name "iptables_manager"
description "The role installing and configuring IPtables"
run_list "recipe[simple_iptables]","recipe[iptables_manager]"
#env_run_lists "prod" => ["recipe[apache2]"], "staging" => ["recipe[apache2::staging]"], "_default" => []
# default_attributes "apache2" => { "listen_ports" => [ "80", "443" ] }
# override_attributes "apache2" => { "max_children" => "50" }
