#!/bin/bash
sudo pip3 install boto3 pprintpp urllib3
echo "Add Command setting ossec.conf in wazuh instance for shellshock attack"
sudo bash -c 'cat >> /var/ossec/etc/ossec.conf << EOF
<ossec_config>
<command>
    <name>aws-dynamodb-add-event</name>
    <executable>aws-dynamodb-add-event</executable>
</command>
<active-response>
        <disabled>no</disabled>
        <command>aws-dynamodb-add-event</command>
        <location>server</location>
        <rules_id>31167,31166,31168,31169</rules_id>
</active-response>
</ossec_config>
EOF'
sudo bash -c 'cat >> /var/ossec/etc/rules/local_rules.conf << EOF
<group name="blacklist_waf,">
  <rule id="100115" level="3">
    <if_sid>657</if_sid>
    <match>active-response/bin/aws-dynamodb-add-event</match>
    <description>Command add Ip blocklist to Waf Active Response</description>
    <group>active_response,pci_dss_11.4,gpg13_4.13,gdpr_IV_35.7.d,nist_800_53_SI.4,tsc_CC6.1,tsc_CC6.8,tsc_CC7.2,tsc_CC7.3,tsc_CC7.4,</group>
  </rule>
</group>
EOF'
sudo bash -c 'cat >> /var/ossec/etc/decoders/local_decoder.xml << EOF
<decoder name="ar_log_json_module">
    <parent>ar_log_json</parent>
    <regex offset="after_parent">"module":"(\.*)"</regex>
    <order>module</order>
</decoder>

<decoder name="ar_log_json_module">
    <parent>ar_log_json</parent>
    <regex offset="after_parent">"command":"(\.*)"</regex>
    <order>command</order>
</decoder>

<decoder name="ar_log_json_module">
    <parent>ar_log_json</parent>
    <regex offset="after_parent">"level":"(\.*)"</regex>
    <order>level</order>
</decoder>

<decoder name="ar_log_json_module">
    <parent>ar_log_json</parent>
    <regex offset="after_parent">"technique":"(\.*)"</regex>
    <order>technique</order>
</decoder>

<decoder name="ar_log_json_module">
    <parent>ar_log_json</parent>
    <regex offset="after_parent">"ip":"(\.*)"</regex>
    <order>ip</order>
</decoder>

<decoder name="ar_log_json_module">
    <parent>ar_log_json</parent>
    <regex offset="after_parent">"srcip":"(\.*)"</regex>
    <order>srcip</order>
</decoder>

<decoder name="ar_log_json_module">
    <parent>ar_log_json</parent>
    <regex offset="after_parent">"url":"(\.*)"</regex>
    <order>url</order>
</decoder>
EOF'
echo "Settig permission" 
echo "Create Scripts and command" 
sudo bash -c 'rm -f /var/ossec/active-response/bin/aws-dynamodb-add-event'
sudo bash -c 'rm -f /var/ossec/active-response/bin/insertIPToDynamoDB.py'
sudo bash -c 'cp /tmp/aws-dynamodb-add-event /var/ossec/active-response/bin/'
sudo bash -c 'cp /tmp/insertIPToDynamoDB.py /var/ossec/active-response/bin/'
sudo chmod 750 /var/ossec/active-response/bin/aws-dynamodb-add-event
sudo chmod 750 /var/ossec/active-response/bin/insertIPToDynamoDB.py
sudo chown root:ossec /var/ossec/active-response/bin/aws-dynamodb-add-event
sudo chown root:ossec /var/ossec/active-response/bin/insertIPToDynamoDB.py
echo "Restart Wazuh "
sudo /var/ossec/bin/wazuh-control restart
