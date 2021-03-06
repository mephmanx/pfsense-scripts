#!/bin/sh

. ../openstack-setup/openstack-env.sh

timestamp(){
   date +"%d.%m.%Y um %H:%M"
}

nextip(){
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 1 ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$NEXT_IP"
}

all_my_code () {

git pull
rm -rf stamp.ver
echo `jot -r 1 1 10000` > stamp.ver

#### Add code here.  code outside is wrapper to detect things run
IFS=

#### empty known_hosts file to set up keys
 > ~/.ssh/known_hosts
######

###### trust hosts
ssh-keyscan -H openstack.lyonsgroup.family >> ~/.ssh/known_hosts
ssh-keyscan -H cloudsupport.lyonsgroup.family >> ~/.ssh/known_hosts
###########

####### Update cert on centos server
####
# If update fails, run this on pfsense router:  ssh-copy-id -i ~/.ssh/id_rsa.pub root@centos (or openstack, if old image)
#####

echo "$CENTOS_ROOT_PWD" | ssh-copy-id -i ~/.ssh/id_rsa.pub root@openstack.lyonsgroup.family

scp /conf/acme/lyonsgroup-wildcard.crt root@openstack.lyonsgroup.family:/tmp

ssh -l root openstack.lyonsgroup.family -i ~/.ssh/id_rsa "
rm -rf /etc/letsencrypt/live/lyonsgroup.family/cert.pem;
mv /tmp/lyonsgroup-wildcard.crt /etc/letsencrypt/live/lyonsgroup.family/cert.pem;
"

scp /conf/acme/lyonsgroup-wildcard.key root@openstack.lyonsgroup.family:/tmp

ssh -l root openstack.lyonsgroup.family -i ~/.ssh/id_rsa "
rm -rf /etc/letsencrypt/live/lyonsgroup.family/privkey.pem;
mv /tmp/lyonsgroup-wildcard.key /etc/letsencrypt/live/lyonsgroup.family/privkey.pem;
"

scp /conf/acme/lyonsgroup-wildcard.ca root@openstack.lyonsgroup.family:/tmp

ssh -l root openstack.lyonsgroup.family -i ~/.ssh/id_rsa "
rm -rf /etc/letsencrypt/live/lyonsgroup.family/chain.pem;
mv /tmp/lyonsgroup-wildcard.ca /etc/letsencrypt/live/lyonsgroup.family/chain.pem;
"

scp /conf/acme/lyonsgroup-wildcard.fullchain root@openstack.lyonsgroup.family:/tmp

ssh -l root openstack.lyonsgroup.family -i ~/.ssh/id_rsa "
rm -rf /etc/letsencrypt/live/lyonsgroup.family/fullchain.pem;
mv /tmp/lyonsgroup-wildcard.fullchain /etc/letsencrypt/live/lyonsgroup.family/fullchain.pem;
"
############################
###########################

############# Update certs on Docker host
####
# If update fails, run this on pfsense router:  ssh-copy-id -i ~/.ssh/id_rsa.pub root@cloudsupport
#####

echo "$CENTOS_ROOT_PWD" | ssh-copy-id -i ~/.ssh/id_rsa.pub root@cloudsupport.lyonsgroup.family

scp /conf/acme/lyonsgroup-wildcard.crt root@cloudsupport.lyonsgroup.family:/tmp

ssh -l root cloudsupport.lyonsgroup.family -i ~/.ssh/id_rsa "
rm -rf /etc/letsencrypt/live/lyonsgroup.family/cert.pem;
mv /tmp/lyonsgroup-wildcard.crt /etc/letsencrypt/live/lyonsgroup.family/cert.pem;
"

scp /conf/acme/lyonsgroup-wildcard.key root@cloudsupport.lyonsgroup.family:/tmp

ssh -l root cloudsupport.lyonsgroup.family -i ~/.ssh/id_rsa "
rm -rf /etc/letsencrypt/live/lyonsgroup.family/privkey.pem;
mv /tmp/lyonsgroup-wildcard.key /etc/letsencrypt/live/lyonsgroup.family/privkey.pem;
"

scp /conf/acme/lyonsgroup-wildcard.ca root@cloudsupport.lyonsgroup.family:/tmp

ssh -l root cloudsupport.lyonsgroup.family -i ~/.ssh/id_rsa "
rm -rf /etc/letsencrypt/live/lyonsgroup.family/chain.pem;
mv /tmp/lyonsgroup-wildcard.ca /etc/letsencrypt/live/lyonsgroup.family/chain.pem;
"

scp /conf/acme/lyonsgroup-wildcard.fullchain root@cloudsupport.lyonsgroup.family:/tmp

ssh -l root cloudsupport.lyonsgroup.family -i ~/.ssh/id_rsa "
rm -rf /etc/letsencrypt/live/lyonsgroup.family/fullchain.pem;
mv /tmp/lyonsgroup-wildcard.fullchain /etc/letsencrypt/live/lyonsgroup.family/fullchain.pem;
"
############################

############################

git add *

git commit -am "Auto Server Commit $(timestamp)"
git push 

}
{ all_my_code |
  logger -p user.notice -t "$(basename "$0")"; } 2>&1 | 
  logger -p user.error -t "$(basename "$0")"
