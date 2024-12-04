from pprint import pprint
import sys
import boto3
import json
import math
import time
import datetime
from datetime import datetime
import ipaddress
from boto3.dynamodb.conditions import Key, Attr
from os import environ
#from botocore.vendored import requests
import urllib3 

#Default Variables
region = 'us-east-1'

#"${SRCIP}" "${AGENTID}" "${RULE}" "${RULEID}" "${URL}"

def insert_ip_dynamoDB(ip,agentid,rule,ruleid,url,blockinstant):
    dynamodb = boto3.resource('dynamodb', region_name=region)
    
    table = dynamodb.Table('Cf_analyserequests_Waf_PROD')
    response = ""
    for number in range(int(blockinstant)):
      now = datetime.utcnow()
      dateT = now.strftime('%Y-%m-%dT%H:%M:%SZ')
      timestamp_blocked = int(now.timestamp())
      response = table.put_item(
       Item={'ID': str(timestamp_blocked)+str(ip),
              'CLIENTIP' : str(ip),
            'SOURCE' : 'ActiveResponse',
            'ENDPOINT' :  url,
            'RULEID' :  str(ruleid)+'-'+str(rule),
            'DATETIME' :  dateT,
            'TIMESTAMP' : timestamp_blocked
            }
      )
      time.sleep(1)
    return response


if __name__ == '__main__':
      response = insert_ip_dynamoDB(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],sys.argv[6])
