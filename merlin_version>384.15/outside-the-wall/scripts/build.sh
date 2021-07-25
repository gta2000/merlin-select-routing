#!/bin/bash

set -e

FILE=${BASH_SOURCE[0]}
pushd `dirname $FILE` > /dev/null
SCRIPT_PATH=`pwd -P`
popd > /dev/null
SCRIPT_FILE=`basename $FILE`


CHINA_IPS_FILE=china_ip_list.txt
echo -e "Downloading Chinese IP Segments file '${CHINA_IPS_FILE}'"
curl -L https://raw.githubusercontent.com/17mon/china_ip_list/master/${CHINA_IPS_FILE} -o ${SCRIPT_PATH}/${CHINA_IPS_FILE}


OUTPUT_PATH=${SCRIPT_PATH}/../downloads

ROUTE_FILE=${OUTPUT_PATH}/02_route.sh

cp ${SCRIPT_PATH}/route_base.sh ${ROUTE_FILE}

while read IP_SEGMENT; do
      echo "route \${OPS} -net ${IP_SEGMENT} \${ROUTE_GW}" >> ${ROUTE_FILE}
done < ${SCRIPT_PATH}/${CHINA_IPS_FILE}
echo -e "Generated  ${ROUTE_FILE}"

cp ${SCRIPT_PATH}/00_check-l2tp.sh ${OUTPUT_PATH}/00_check-l2tp.sh
echo -e "Copied  ${OUTPUT_PATH}/00_check-l2tp.sh"

cp ${SCRIPT_PATH}/01_post-l2tp.sh ${OUTPUT_PATH}/01_post-l2tp.sh
echo -e "Copied  ${OUTPUT_PATH}/01_post-l2tp.sh"

cp ${SCRIPT_PATH}/wan-event ${OUTPUT_PATH}/wan-event
echo -e "Copied  ${OUTPUT_PATH}/wan-event"

echo -e "Downloading accelerated-domains.china.conf ..."
DNSMASQ_FILE=${OUTPUT_PATH}/dnsmasq.conf.add
curl -L https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf -o ${DNSMASQ_FILE}

sed -i '' '/server=\/static.licdn.com\/114.114.114.114/d' ${DNSMASQ_FILE}
echo -e "Removed  Linkedin CDN"

echo -e "Generated  ${DNSMASQ_FILE}"

echo -e "---- DONE ----"
