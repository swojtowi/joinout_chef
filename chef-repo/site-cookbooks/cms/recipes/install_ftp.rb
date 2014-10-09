
node.default["proftpd"]["conf"]["server_name"] = "FTP by JoinOut"
node.default["proftpd"]["conf"]["defer_welcome"] = true
node.default['proftpd']['conf']['default_root'] = '~'

include_recipe "onddo_proftpd"