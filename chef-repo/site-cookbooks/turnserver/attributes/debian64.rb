

default['debian64']['coturn']="coturn_4.1.2.1-1_amd64.deb"
default['debian64']['iprules']=["iptables -I INPUT -p udp --dport 58745 -j ACCEPT","iptables -I INPUT -p udp --dport 5766 -j ACCEPT","iptables -I INPUT -p udp --dport 3479 -j ACCEPT","iptables -I INPUT -p udp --dport 3478 -j ACCEPT","iptables -I INPUT -p tcp --dport 5766 -j ACCEPT","iptables -I INPUT -p tcp --dport 3479 -j ACCEPT","iptables -I INPUT -p tcp --dport 3478 -j ACCEPT","iptables -I INPUT -p tcp --dport 5432 -j ACCEPT","iptables -I INPUT -p tcp --dport 3306 -j ACCEPT"]

default['debian64']['mysql']['on'] = ["chkconfig mysqld on"]#,"mysqladmin -u root password '123123'"]
default['debian64']['mysql']['addUsers']['longTerm'] = ["turnadmin -a -M \"host=localhost dbname=turn user=turn password=turn\" -u gorst -r north.gov -p hero","turnadmin -a -M \"host=localhost dbname=turn user=turn password=turn\" -u ninefingers -r north.gov -p youhavetoberealistic"]
default['debian64']['CreateTurnserver']="createTurnUser.sql"
default['debian64']['schema']= "schema.sql"
default['debian64']['template']['turnserver'] = ["#{default['debian64']['CreateTurnserver']}","#{default['debian64']['schema']}"]
