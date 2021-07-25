#!/bin/sh

Say(){
   echo -e $$ $@ | logger -st "[$(basename $0)]"
}

Say "Remove existing certificate"
rm -rf /jffs/.le
Say "Restart letsencrypt service"
service restart_letsencrypt
