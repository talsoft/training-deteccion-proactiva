#!/bin/sh
# Custom OSSEC block / Easily modifiable for custom responses (touch a file, insert to db, etc).
# Expect: srcip
# 

ACTION=$1
USER=$2
IP=$3

# Extra arguments
read INPUT_JSON
AGENTID=$(echo $INPUT_JSON | jq -r .parameters.alert.agent.id)
RULE=$(echo $INPUT_JSON | jq -r .parameters.alert.rule.description)
RULEID=$(echo $INPUT_JSON | jq -r .parameters.alert.rule.id)
SRCIP=$(echo $INPUT_JSON | jq -r .parameters.alert.data.srcip)
IDCODE=$(echo $INPUT_JSON | jq -r .parameters.alert.data.id)
URL=$(echo $INPUT_JSON | jq -r .parameters.alert.data.url)


COMMAND=$(echo $INPUT_JSON | jq -r .command)

LOCAL=`dirname $0`;
cd $LOCAL
cd ../
PWD=`pwd`


# Logging the call
echo "`date` $0 $1 $2 $3 $4 $5" >> ${PWD}/../logs/active-responses.log


# IP Address must be provided
if [ "x${IP}" = "x" ]; then
   echo "$0: Missing argument <action> <user> (ip)" 
   exit 1;
fi


# Custom block (touching a file inside /ipblock/IP)
if [ "x${ACTION}" = "xadd" ]; then
    python insertIPToDynamoDB.py "${SRCIP}" "${AGENTID}" "${RULE}" "${RULEID}" "${IDCODE}" "${URL}"
   # touch "/ipblock/${IP}"
elif [ "x${ACTION}" = "xdelete" ]; then   
  #  rm -f "/ipblock/${IP}"
    python removeIpFromWAF.py ${IP}
# Invalid action   
else
   echo "$0: invalid action: ${ACTION}"
fi       

exit 1;
