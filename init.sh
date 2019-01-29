#!/usr/bin/env bash

function terminator() { 
  echo 
  echo "Terminating pid $child...." 
  kill -TERM "$child" 2>/dev/null
  echo "Exiting."
}

trap terminator SIGHUP SIGINT SIGQUIT SIGTERM
echo launch.sh runing as user $(id -un):$(id -gn)\($(id -u):$(id -g)\)

# Overhauling userbase
echo "root:x:0:root" > /etc/group
echo "root:x:0:0:root:/root:/bin/ash" > /etc/passwd
if [ $GRP_ID -ne 0 ]; then addgroup -g $GRP_ID -S duplicacy; fi
if [ $USR_ID -ne 0 ]; then adduser -u $USR_ID -S duplicacy -G duplicacy; fi
 
# Configuring folders and permissions    
mkdir -p    /config /logs /cache
chown -R $USR_ID:$GRP_ID    /config /logs /cache

if [ "$PERSISTENT_MACHINE_ID" == "true" ]; then
    if [ -f /config/machine-id ]; then 
        cp /config/machine-id /var/lib/dbus/machine-id
    else
        cp /var/lib/dbus/machine-id /config/machine-id
    fi
fi

chmod o+r,g+r /var/lib/dbus/machine-id

echo Using machine-id = $(cat /var/lib/dbus/machine-id)

# Starting child process
su-exec $USR_ID:$GRP_ID launch.sh & 

child=$! 

wait "$child"