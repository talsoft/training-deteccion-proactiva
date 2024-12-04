#!/bin/bash
echo "Add Command and setting ossec.conf in wazuh instance malicious process and export command"
sudo bash -c 'cat >> /etc/shared/Container/agent.conf << EOF
<agent_config>
    <!-- Shared agent configuration here -->
    <rootcheck>
      <system_audit>/var/ossec/etc/shared/cis_debian_linux_rcl.txt</system_audit>
      <system_audit>/var/ossec/etc/shared/system_audit_rcl.txt</system_audit>
      <system_audit>/var/ossec/etc/shared/system_audit_ssh.txt</system_audit>
    </rootcheck>
<wodle name="command">
    <disabled>no</disabled>
    <tag>ps-list</tag>
    <command>ps -eo user,pid,cmd</command>
    <interval>20s</interval>
    <ignore_output>no</ignore_output>
    <run_on_start>yes</run_on_start>
    <timeout>5</timeout>
</wodle>
<wodle name="command">
    <disabled>no</disabled>
    <tag>set-env</tag>  
    <command>/bin/bash /var/ossec/etc/shared/setpreexec.sh</command>
    <skip_verification>yes</skip_verification>
    <interval>30d</interval>
    <ignore_output>no</ignore_output>
    <run_on_start>yes</run_on_start>
    <timeout>5</timeout>
</wodle>
<wodle name="command">
    <disabled>no</disabled>
    <tag>detect-env</tag>
    <command>/bin/bash /var/ossec/etc/shared/check_export_history.sh</command>
    <interval>300s</interval>
    <skip_verification>yes</skip_verification>
    <ignore_output>no</ignore_output>
    <run_on_start>yes</run_on_start>
    <timeout>5</timeout>
</wodle>
</agent_config>
<agent_config>
    <localfile>
        <log_format>syslog</log_format>
        <location>/var/ossec/logs/active-responses.log</location>
    </localfile>
</agent_config>
EOF'
sudo bash -c 'cat >> /var/ossec/etc/rules/local_rules.xml << EOF
<!--Detect Metasploit meterpreter-->
<group name="wazuh,">
    <rule id="100002" level="0">
        <location>command_ps-list</location>
        <description>List of running process.</description>
        <group>process_monitor,</group>
    </rule>
 
    <rule id="100003" level="14">
        <if_sid>100002</if_sid>
        <match>eval(base64_decode</match>
        <description>Reverse shell detected.</description>
        <group>process_monitor,attacks</group>
    </rule>
    <rule id="100004" level="14">
        <if_sid>100002</if_sid>
        <match>-server http</match>
        <description>Possible C2C Reverse shell detected.</description>
        <group>process_monitor,attacks</group>
    </rule>
    <rule id="100005" level="14">
        <if_sid>100002</if_sid>
        <match>-http http</match>
        <description>Possible C2C Reverse shell detected.</description>
        <group>process_monitor,attacks</group>
    </rule>
    <rule id="100006" level="0">
        <location>command_detect-env</location>
        <description>Search export or env command execution. Exfiltratation system variables.</description>
        <group>process_monitor</group>
        <mitre>
            <id>T1020</id>
            <id>T1041</id>
        </mitre>
    </rule>
    <rule id="100007" level="12">
        <if_sid>100006</if_sid>
        <match>env</match>
        <description>Exfiltratation of system variables detected.</description>
        <group>process_monitor,attacks,automatic_attack</group>
        <mitre>
            <id>T1020</id>
            <id>T1041</id>
        </mitre>
    </rule>
     <rule id="100008" level="12">
        <if_sid>100006</if_sid>
        <match>export</match>
        <description>Exfiltratation of system variables detected.</description>
        <group>process_monitor,attacks,automatic_attack</group>
        <mitre>
            <id>T1020</id>
            <id>T1041</id>
        </mitre>
    </rule>
    <rule id="100009" level="15">
        <if_sid>100006</if_sid>
        <match>LinEnum</match>
        <description>Exfiltratation execution LinEnum.sh detected.</description>
        <group>process_monitor,attacks,automatic_attack</group>
        <mitre>
            <id>T1020</id>
            <id>T1041</id>
        </mitre>
    </rule>
    <rule id="100010" level="15">
        <if_sid>100002</if_sid>
        <match>LinEnum.sh</match>
        <description>Exfiltratation execution LinEnum.sh detected.</description>
        <group>process_monitor,attacks,automatic_attack</group>
        <mitre>
            <id>T1020</id>
            <id>T1041</id>
        </mitre>
    </rule>
    <rule id="100011" level="10">
        <if_sid>100002</if_sid>
        <match>curl</match>
        <description>Command execution curl detected.</description>
        <group>process_monitor,attacks,automatic_attack</group>
        <mitre>
            <id>T1020</id>
            <id>T1041</id>
        </mitre>
    </rule>
     <rule id="100012" level="10">
        <if_sid>100002</if_sid>
        <match>wget</match>
        <description>Command execution wget detected.</description>
        <group>process_monitor,attacks,automatic_attack</group>
        <mitre>
            <id>T1020</id>
            <id>T1041</id>
        </mitre>
    </rule>
    <rule id="100013" level="10">
        <if_sid>100006</if_sid>
        <match>wget</match>
        <description>Process execution wget detected.</description>
        <group>process_monitor,attacks,automatic_attack</group>
        <mitre>
            <id>T1020</id>
            <id>T1041</id>
        </mitre>
    </rule>
    <rule id="100014" level="10">
        <if_sid>100006</if_sid>
        <match>wget</match>
        <description>Process execution curl detected.</description>
        <group>process_monitor,attacks,automatic_attack</group>
        <mitre>
            <id>T1020</id>
            <id>T1041</id>
        </mitre>
    </rule>
</group>
EOF'
echo "Settig permission" 
echo "Create Scripts and command" 
echo "Setting Container config"
sudo bash -c 'cp /tmp/check_command.sh /var/ossec/etc/shared/Container/'
sudo bash -c 'cp /tmp/check_export_history.sh /var/ossec/etc/shared/Container/'
sudo bash -c 'cp /tmp/setpreexec.sh /var/ossec/etc/shared/Container/'
echo "Setting default config"
sudo bash -c 'cp /tmp/check_command.sh /var/ossec/etc/shared/default/'
sudo bash -c 'cp /tmp/check_export_history.sh /var/ossec/etc/shared/default/'
sudo bash -c 'cp /tmp/setpreexec.sh /var/ossec/etc/shared/default/'
sudo chmod 750 /var/ossec/etc/shared/default/check_command.sh
sudo chmod 750 /var/ossec/etc/shared/default/check_export_history.sh
sudo chmod 750 /var/ossec/etc/shared/default/setpreexec.sh
sudo chown root:ossec /var/ossec/etc/shared/default/check_command.sh
sudo chown root:ossec /var/ossec/etc/shared/default/check_export_history.sh
sudo chown root:ossec /var/ossec/etc/shared/default/setpreexec.sh
echo "Restart Wazuh "
sudo /var/ossec/bin/wazuh-control restart
