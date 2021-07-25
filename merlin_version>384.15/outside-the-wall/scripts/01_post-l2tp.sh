#!/bin/sh

Say(){
   echo -e $$ $@ | logger -st "[$(basename $0)]"
}

VPN_GW="`nvram get vpnc_gateway`"
VPN_NET=${VPN_GW%?}0

Say "Removing L2TP default route"
ip route delete 0.0.0.0/1 dev ppp5 >> /tmp/syslog.log
ip route delete 128.0.0.0/1 dev ppp5 >> /tmp/syslog.log
Say "Done"

Say "Adding L2TP static route to [${VPN_NET}]"
route -n add -net ${VPN_NET} netmask 255.255.255.0 ppp5 >> /tmp/syslog.log
Say "Done"

Say "Adding China IP routes"
/jffs/scripts/02_route.sh add >> /tmp/syslog.log
Say "Done"
