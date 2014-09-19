

default['centos6.5']['packages'] = ["kernel-devel","openssl","telnet","mysql","perl","postgresql-libs","libevent"] #,"hiredis"
#default['centos6.5']['perl-DBI']=["perl #{Chef::Config[:file_cache_path]}/Makefile.PL","make","make test","make install"]
default['centos6.5']['rpm'] = ["turnserver-4.1.2.1-0.el6.x86_64.rpm","turnserver-client-libs-4.1.2.1-0.el6.x86_64.rpm","turnserver-utils-4.1.2.1-0.el6.x86_64.rpm"] #"libevent-2.0.21-2.el6.x86_64.rpm"
default['centos6.5']['mysql']['on'] = ["chkconfig mysqld on","mysqladmin -u root password '123123'"]
default['centos6.5']['mysql']['addUsers']['longTerm'] = ["turnadmin -a -M \"host=localhost dbname=turn user=turn password=turn\" -u gorst -r north.gov -p hero","turnadmin -a -M \"host=localhost dbname=turn user=turn password=turn\" -u ninefingers -r north.gov -p youhavetoberealistic"]
