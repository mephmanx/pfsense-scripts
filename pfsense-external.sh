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

rm -rf *.info

#### Add code here.  code outside is wrapper to detect things run

#### fetch external IP.  should be updated vi godaddy/pfsense integration

myip=`curl -s "https://api.ipify.org"`

###########

#### update external IP, external +1
mydomain="lyonsgroup.family"
myhostname="app-external"
gdapikey="e4CDttXYZYqD_Y9fRirgZfkcKtwuMfDJdTf:2r7JhQudVES1n6wnbZLk9m"
logdest="external.info"
#external_ip=$(nextip $myip)
external_ip=$myip
dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "https://api.godaddy.com/v1/domains/${mydomain}/records/A/${myhostname}"`
gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
echo "`date '+%Y-%m-%d %H:%M:%S'` - Current External IP is $external_ip, GoDaddy DNS IP is $gdip"

if [ "$gdip" != "$external_ip" -a "$external_ip" != "" ]; then
  echo "IP has changed!! Updating on GoDaddy"
  curl -s -X PUT "https://api.godaddy.com/v1/domains/${mydomain}/records/A/${myhostname}" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${external_ip}\"}]"
  logger -p $logdest "Changed IP on ${hostname}.${mydomain} from ${gdip} to ${external_ip}"
fi
#########

##### update internal IP, external +2

mydomain="lyonsgroup.family"
myhostname="app-internal"
gdapikey="e4CDttXYZYqD_Y9fRirgZfkcKtwuMfDJdTf:2r7JhQudVES1n6wnbZLk9m"
logdest="internal.info"
#internal_ip=$(nextip $external_ip)
internal_ip=$myip
dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "https://api.godaddy.com/v1/domains/${mydomain}/records/A/${myhostname}"`
gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
echo "`date '+%Y-%m-%d %H:%M:%S'` - Current External IP is $internal_ip, GoDaddy DNS IP is $gdip"

if [ "$gdip" != "$internal_ip" -a "$internal_ip" != "" ]; then
  echo "IP has changed!! Updating on GoDaddy"
  curl -s -X PUT "https://api.godaddy.com/v1/domains/${mydomain}/records/A/${myhostname}" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${internal_ip}\"}]"
  logger -p $logdest "Changed IP on ${hostname}.${mydomain} from ${gdip} to ${internal_ip}"
fi

##############

git add *

git commit -am "Auto Server Commit $(timestamp)"
git push 

}
{ all_my_code |
  logger -p user.notice -t "$(basename "$0")"; } 2>&1 | 
  logger -p user.error -t "$(basename "$0")"
