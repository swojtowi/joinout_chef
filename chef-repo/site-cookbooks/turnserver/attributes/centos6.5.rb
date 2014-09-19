
default['directories']['create']=["root/rpmbuild","root/rpmbuild/SOURCES","root/rpmbuild/SPECS"]


default["libevent"]["download"]=["./configure && make","make install"]
#default["libevent"]["install"]=["./configure --prefix=/bin --disable-static &&
#make","make install","make clean"]
default['centos6.5']['packages'] = ["make","gcc","gcc-c++","wget","openssl","openssl-devel","libevent","libevent-devel","kernel-devel","telnet","mysql-server","mysql","perl","postgresql-libs","hiredis"] #,"hiredis"
#default['centos6.5']['perl-DBI']=["perl #{Chef::Config[:file_cache_path]}/Makefile.PL","make","make test","make install"]
default['libevent']['rpm']= ["/root/rpmbuild/RPMS/x86_64/libevent-2.0.21-2.el6.x86_64.rpm","/root/rpmbuild/RPMS/x86_64/libevent-devel-2.0.21-2.el6.x86_64.rpm","/root/rpmbuild/RPMS/x86_64/libevent-debuginfo-2.0.21-2.el6.x86_64.rpm"]


default['centos6.5']['rpm'] = ["libevent-2.0.21-2.el6.x86_64.rpm","turnserver-4.1.2.1-0.el6.x86_64.rpm","turnserver-client-libs-4.1.2.1-0.el6.x86_64.rpm","turnserver-utils-4.1.2.1-0.el6.x86_64.rpm"] #"libevent-2.0.21-2.el6.x86_64.rpm"
default['centos6.5']['mysql']['on'] = ["chkconfig mysqld on","mysqladmin -u root password '123123'"]
default['centos6.5']['mysql']['addUsers']['longTerm'] = ["turnadmin -a -M \"host=localhost dbname=turn user=turn password=turn\" -u gorst -r north.gov -p hero","turnadmin -a -M \"host=localhost dbname=turn user=turn password=turn\" -u ninefingers -r north.gov -p youhavetoberealistic"]
#/Users/davidsiecinski/Downloads/libevent-2.0.21-stable (1).tar.gz


# ln -s /usr/local/libexec/* /usr/bin/