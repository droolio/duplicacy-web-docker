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
#
echo "root:x:0:root" > /etc/group
echo "root:x:0:0:root:/root:/bin/ash" > /etc/passwd
if [ $GRP_ID -ne 0 ]; then 
    addgroup -g $GRP_ID -S duplicacy; 
fi
if [ $USR_ID -ne 0 ]; then 
    adduser -u $USR_ID -S duplicacy -G duplicacy; 
fi
 
# Configuring folders and permissions   
# 
mkdir -p                    /config/bin /logs /cache
chown -R $USR_ID:$GRP_ID    /config     /logs /cache

# Find correct architecture 
# 
MACHINE_ARCH=$(uname -m)

case ${MACHINE_ARCH} in
"x86_64")
    ARCH=x64
    ;;
"arm")
    ARCH=arm
    ;;
*)
    echo Unknown or unsupported architecture ${MACHINE_ARCH}
    exit 1
    ;;
esac

# Target application filename and URL
#
APPFILE=duplicacy_web_linux_${ARCH}_${DUPLICACY_WEB_VERSION}
URL=https://acrosync.com/duplicacy-web/${APPFILE}
export APPFILEPATH=/config/bin/${APPFILE}

# If application executable hasn't been downloaded yet -- do it now
#
if [ ! -f ${APPFILEPATH} ]; then
    echo "Downloading executable from ${URL}"
    wget -O ${APPFILEPATH} ${URL}
    if [[ $? != 0 ]]; then
        echo "Download failed"
        rm -f ${APPFILEPATH}
        exit 2
    fi
    chmod +x ${APPFILEPATH}  || exit 3
fi


# Preparing persistent unique machine ID
#
if ! dbus-uuidgen --ensure=/config/machine-id; then 
    echo machine-id contains invalid data. Regenerating.
    dbus-uuidgen > /config/machine-id
fi

echo Using machine-id = $(cat /var/lib/dbus/machine-id)

# Starting child process
#
su-exec $USR_ID:$GRP_ID launch.sh & 

child=$! 

wait "$child"