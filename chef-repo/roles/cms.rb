name "cms"
description "The role installing and configuring WordPress CMS"
run_list "recipe[cms::install_wordpress]", "recipe[cms::configure_wordpress]"
# env_run_lists "prod" => ["recipe[apache2]"], "staging" => ["recipe[apache2::staging]"], "_default" => []
# default_attributes "apache2" => { "listen_ports" => [ "80", "443" ] }
# override_attributes "apache2" => { "max_children" => "50" }
