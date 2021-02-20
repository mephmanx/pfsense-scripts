#!/bin/sh

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

crt=`cat /conf/acme/esxi.crt`

ssh -l root esxi.lyonsgroup.family -i ~/.ssh/id_rsa "
rm -rf /etc/vmware/ssl/rui.crt.bk;
#mv /etc/vmware/ssl/rui.crt /etc/vmware/ssl/rui.crt.bk;
echo "$crt" > /etc/vmware/ssl/rui.crt-test;
"

key=`cat /conf/acme/esxi.key`

ssh -l root esxi.lyonsgroup.family -i ~/.ssh/id_rsa "
rm -rf /etc/vmware/ssl/rui.key.bk;
#mv /etc/vmware/ssl/rui.key /etc/vmware/ssl/rui.key.bk;
echo "$key" > /etc/vmware/ssl/rui.key-test;
"

############################

git add *

git commit -am "Auto Server Commit $(timestamp)"
git push 

}
{ all_my_code |
  logger -p user.notice -t "$(basename "$0")"; } 2>&1 | 
  logger -p user.error -t "$(basename "$0")"
