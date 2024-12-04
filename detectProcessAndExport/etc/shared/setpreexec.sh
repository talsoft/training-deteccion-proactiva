#!/bin/bash
if [ ! -f "/root/.bash-preexec.sh" ]; then
    # Pull down our file from GitHub and write it to our home directory as a hidden file.
    curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o /root/.bash-preexec.sh
    # Source our file at the end of our bash profile (e.g. ~/.bashrc, ~/.profile, or ~/.bash_profile)
    echo '[[ -f /root/.bash-preexec.sh ]] && source /root/.bash-preexec.sh' >> /root/.bashrc
    echo 'preexec_set() { /tmp/check_command.sh $1; }' >>  /root/.bashrc
    echo 'preexec_functions+=(preexec_set)' >> /root/.bashrc
    source /root/.bashrc
fi
cp /var/ossec/etc/shared/check_command.sh /tmp/check_command.sh
chown root:root /tmp/check_command.sh
chmod +x /tmp/check_command.sh
chmod 775 /tmp/check.log
