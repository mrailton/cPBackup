#!/bin/bash
# Script to create cPanel backups and copy to a remote server
# For security purposes, assumes you have enabled ssh keyl based authentication between servers.
# Written by Mark Railton - markrailton.com - bitbucket.org/railto

# Variables to make script easier to configure for your needs
user="backup" # Username on remote backup host
server="srv3.markrailton.com" # Server name of remote backup host
path="~/backups/srv1/" # Path on remote backup host to store backup files
threshold="1.00" # Load threshold above which backups will not run
check="10" # Time in seconds between load checks when above threshold

#  Check server load and only run if below threshold

while [ 1 ]; do
	load=`cat /proc/loadavg | awk '{print $1}'`
	if [ ${load%%.*} -ge ${threshold%%.*} ]; then
		echo "Server load too high, trying again in $check seconds"
		sleep $check
	else
		echo "Server load below threshold, running backup"
		break
	fi
done

# Remove existing backup files

echo ""
echo "Removing any existing backup files"
echo ""
rm -f /home/cpmove*

# Backup all accounts

echo ""
echo "Creating backup files"
echo ""
ls /var/cpanel/users/ | while read account; do
/scripts/pkgacct $account
echo ""
echo "Backup for $account created"
echo ""
done

# SCP Files to remote host

echo ""
echo "Copying backup files to remote server"
echo ""
scp /home/cpmove* $user@$server:$path
echo ""
echo "Backup Files Copied to remote server"
echo ""

# Remove backup files from local host

echo ""
echo "Removing backup files from local server"
echo ""
rm -f /home/cpmove*

# Backup complete, exit
exit 0