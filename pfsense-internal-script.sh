#!/bin/sh

timestamp(){
   date +"%d.%m.%Y um %H:%M"
}

all_my_code () {

git pull
rm -rf stamp-internal.ver
echo `jot -r 1 1 10000` > stamp-internal.ver

#### Add code here.  code outside is wrapper to detect things run




##############

git add *

git commit -am "Auto Server Commit $(timestamp)"
git push 

}
{ all_my_code |
  logger -p user.notice -t "$(basename "$0")"; } 2>&1 | 
  logger -p user.error -t "$(basename "$0")"
