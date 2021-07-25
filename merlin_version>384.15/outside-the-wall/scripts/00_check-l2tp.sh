#!/bin/sh

Say(){
   echo -e $$ $@ | logger -st "[$(basename $0)]"
}

Check(){
   local VPN_ROUTE=`ip route | grep "0.0.0.0/1 via"`

   if [ ! -z "$VPN_ROUTE" ]; then
	Say "Add China Route";
	sh /jffs/scripts/01_post-l2tp.sh;
   fi
}

Check