#!/bin/sh
echo "Cmnd_Alias UPDATECA = /usr/sbin/update-ca-certificates" >> /etc/sudoers
echo "%sudo ALL=NOPASSWD: UPDATECA" >> /etc/sudoers