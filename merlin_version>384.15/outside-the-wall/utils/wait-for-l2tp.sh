#!/bin/sh
#Refer to https://www.snbforums.com/threads/l2tp-vpn-client-for-only-one-device.37927/

Say(){
   echo -e $$ $@ | logger -st "[$(basename $0)]"
}
ANSIColours() {
    cRESET="\e[0m";cBLA="\e[30m";cRED="\e[31m";cGRE="\e[32m";cYEL="\e[33m";cBLU="\e[34m";cMAG="\e[35m";cCYA="\e[36m";cGRA="\e[37m";cFGRESET="\e[39m"
    cBGRA="\e[90m";cBRED="\e[91m";cBGRE="\e[92m";cBYEL="\e[93m";cBBLU="\e[94m";cBMAG="\e[95m";cBCYA="\e[96m";cBWHT="\e[97m"
    aBOLD="\e[1m";aDIM="\e[2m";aUNDER="\e[4m";aBLINK="\e[5m";aREVERSE="\e[7m"
    aBOLDr="\e[21m";aDIMr="\e[22m";aUNDERr="\e[24m";aBLINKr="\e[25m";aREVERSEr="\e[27m"
    cWRED="\e[41m";cWGRE="\e[42m";cWYEL="\e[43m";cWBLU="\e[44m";cWMAG="\e[45m";cWCYA="\e[46m";cWGRA="\e[47m"
    cYBLU="\e[93;48;5;21m"
    xHOME="\e[H";xERASE="\e[K";xERASEDOWN="\e[J";xERASEUP="\e[1J";xCSRPOS="\e[s";xPOSCSR="\e[u"
}
Check_PPTP_L2TPState(){

      local I=0
      local OK=0
      local IFNAME=$2

      if [ "$1" = "2" ]; then
         local WSTATE="connect"
         local WAIT_TXT="may take 20-30 secs"
      fi
      if [ "$1" = "0" ]; then
         local WSTATE="disconnect"
         local WAIT_TXT="may take 10 secs"
      fi

      echo -e $cBCYA >&2
      Say "Waiting $3 secs for" $PROTOCOL "VPN Client ("$VPNTAG") to" $WSTATE"....."$WAIT_TXT

      echo -e $cBRED >&2
      while [ $I -lt $3 ]; do
        sleep 1
        #Say "Waiting for" $PROTOCOL "VPN Client to" $WSTATE"....." $i
        local STATUS=$(ifconfig $IFNAME 2> /dev/null)
        if [ -z "$STATUS" ] && [ "$WSTATE" == "disconnect" ];then
           OK="1"
           break
        fi

        # Explicity check for 'UP' rather than 'POINTOPOINT' as it can take a few secs after PPP5 exists to actually show 'UP'
        local STATUS=$(ifconfig $IFNAME 2> /dev/null | grep -o "UP")
        if [ ! -z "$STATUS" ] && [ "$WSTATE" == "connect" ];then
           OK="1"
           break
        fi

        I=$((I + 1))

      done

      if [ "$OK" = "1" ];then
            echo -e $cBYEL >&2
            Say $PROTOCOL "VPN Client ("$VPNTAG")" $WSTATE"'d in" $I "secs"
            echo -e $cBRED >&2
            echo 0
            return 0
      else
            echo -e  >&2
            Say "***ERROR***" $PROTOCOL "VPN Client ("$VPNTAG") FAILED to" $WSTATE "after" $I "secs"
            echo -e "\a" >&2
            echo 1
            return 1
      fi
 
}


ANSIColours
PROTOCOL="L2TP"
VPNTAG="ppp5"

RC=$(Check_PPTP_L2TPState "2" "$VPNTAG" "20")               # Wait 20 secs, and use '2' as 'connect' status (similar to OpenVPN)
[ $RC -eq 0 ] && { Say "Selective Routing configuration starting"; /jffs/scripts/01_post-l2tp.sh; }