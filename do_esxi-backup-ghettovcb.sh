#!/bin/bash

MAIL_FROM=from@example.com
MAIL_TO=to@example.com


#log rotate
for OLD in 6 5 4 3 2 1  ; do
	if [ -f /srv/backuplog/esxi.log.$OLD ] ; then
		NEW=$[ $OLD + 1 ]
		# save date
		touch /srv/backuplog/.esxitimestamp -r /srv/backuplog/esxi.log.$OLD
		mv /srv/backuplog/esxi.log.$OLD /srv/backuplog/esxi.log.$NEW
		# reapply date
		touch /srv/backuplog/esxi.log.$NEW -r /srv/backuplog/.esxitimestamp
	fi
done

# backup and rotate
/srv/bin/backup/esxi-backup-ghettovcb.sh 2>&1 | tee /srv/backuplog/esxi.log.0
sync

# send log and status via mail
STATUS=`grep ERROR /srv/backuplog/esxi.log.0 >/dev/null 2>&1 && echo ERROR || echo OK;`;
cat /srv/backuplog/esxi.log.0 | mail ${MAIL_FROM} -s "Backup status for ESXi `date +"%Y-%m-%d"`: ${STATUS}" ${MAIL_TO}

# save logfile
cp /srv/backuplog/esxi.log.0 /srv/backuplog/esxi.log.1
