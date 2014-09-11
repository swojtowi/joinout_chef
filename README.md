# JoinOut

In instruction below please ensure that you use proper path(s) :)

## Directory contents:

* joinout_server - contains frontend application

* joinout_fe - contains backend application

* joinout_util - contains nginx configuration and cleanning script

* video-chat - contains video-chat lib and demo which is used on http://www.joinout.pl page

## Installation Guide (on Amazon)

### Install rfc5766-turn-server on Amazon 

1. change region to Oregon (we will use predefined AMI with rfc5766-turn-server)

2. define proper security group in AWS Console turn-security-group

3. using *knife* create new instance, i.e. 

    *knife ec2 server create -I ami-6e4f245e --flavor=m3.medium --ssh-user ec2-user --identity-file=/root/.ssh/aws-ipq-bigdata-us-oregon.pem  --groups=turn-security-group --ssh-key aws-ipq-bigdata-us-oregon --region us-west-2 --availability-zone us-west-2c*
    

### Install necessary tools and libraries

1. ssh to EC2 instance, i.e. 
    
    *ssh -i /root/.ssh/aws-ipq-bigdata-us-oregon.pem ec2-user@54.245.236.20*

2. install Git: 

    *sudo yum -y install git-core*

3. install node.js

    *sudo rpm --import https://fedoraproject.org/static/0608B895.txt*
    
    *sudo rpm -Uvh http://download-i2.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm*
    
    *sudo yum -y install nodejs npm --enablerepo=epel*

4. install PeerJS

    *npm install peer*

5. install MongoDB

    create file mongodb.repo

    *sudo vim /etc/yum.repos.d/mongodb.repo*
    
    add the following content

    *[mongodb]*

     *name=MongoDB Repository*
     
     *baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/*
     
     *gpgcheck=0*
     
     *enabled=1*

    install mongo
    
    *sudo yum -y install mongodb-org*

6. clone gitlab repo with Joinout source code

    *git clone https://code.impaqgroup.com/m2mcc/joinout.git*

7. install necessary libraries for joinout server

    *cd joinout/joinout_server/*
    
    *npm install*

8. install and configure joinout frontend

    correct URLs in file joinout/joinout_fe/public/js/controllers.js
    
    *cd joinout/joinout_fe/*
    
    *npm install*

9. install and configure nginx

    *sudo yum -y install nginx*

    make a backup copy of original nginx.conf
    
    *sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig*

    copy new nginx.conf

    *sudo cp joinout/joinout_util/nginx.conf /etc/nginx/*

10. install forever

    *sudo npm install -g forever*


## Start Joinout

1. Run the PeerJSServer

    *cd*
    
    *cd node_modules/peer/bin*
    
    *./peerjs --port 9000 &*

2. Start MongoDB

    *sudo service mongod start*

3. start Joinout Server (NOTICE: we log everything !!!)

    *cd*

    *cd joinout/joinout_server/*
    
    *forever start -l joinout_server_forever.log -o joinout_servere_out.log -e joinout_server_err.log joinout_backend.js*

4. start JoinOut Frontend

    *cd*

    *cd joinout/joinout_fe/*

    *forever start -l joinout_fe_forever.log -o joinout_fe_out.log -e joinout_fe_err.log joinout_frontend.js*
    
5. start nginx

    *sudo chkconfig nginx on*
    
    *sudo service nginx start*

6. add cron task to cleanup data from old users

    *crontab -e*

    *\* \* \* \* \* mongo joinout_util/cleanmongo.js*


7. go to web browser and check

    http://54.245.236.20/joinout/

## Verify if JoinOut server is running

1. try to execute following curl methods

    // GET a List of Users

    *curl http://54.245.236.20/api/users*

    // CREATE a Single User
    
    *curl -i -X POST  http://54.245.236.20/api/users -d '{ "user_name":"John Rabmo", "user_id":"997" }'*
    
    
    
# Ports

PeerJS 9000

JoinOut Server 8080

JoinOut FrontEnd 9090






