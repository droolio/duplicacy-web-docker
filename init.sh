#!/usr/bin/env bash

readonly ERROR_UNSUPPORTED_ARCHITECTURE=1
readonly ERROR_NO_LOCAL_BINARY_AVAILABLE=2
readonly ERROR_DOWNLOAD_FAILED=3
readonly ERROR_CHMOD_FAILED=4

readonly URL_VERSION_CHECK='https://duplicacy.com/latest_web_version'
readonly URL_DUPLICACY_WEB='https://acrosync.com/duplicacy-web'
readonly FILE_DATE_CHECKER=/tmp/date-checker

function terminator() { 
  echo 
  echo "Terminating pid $child...." 
  kill -TERM "$child" 2>/dev/null
  echo "Exiting."
}

trap terminator SIGHUP SIGINT SIGQUIT SIGTERM
echo init.sh runing as user $(id -un):$(id -gn)\($(id -u):$(id -g)\)

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
x86_64)
    ARCH=x64
    ;;
arm|armv7l)
    ARCH=arm
    ;;
*)
    echo Unknown or unsupported architecture ${MACHINE_ARCH}
    exit ${ERROR_UNSUPPORTED_ARCHITECTURE}
    ;;
esac

# Determine available versions for Latest and Stable channels: 
#
case ${DUPLICACY_WEB_VERSION} in
Stable|Latest|stable|latest)
    printf "Remote available versions... " 
    AVAILABLE_VERSIONS=$(curl -s ${URL_VERSION_CHECK})
    LATEST_AVAILABLE_VERSION=$(echo ${AVAILABLE_VERSIONS} | jq -r '.latest' 2>/dev/null)
    STABLE_AVAILABLE_VERSION=$(echo ${AVAILABLE_VERSIONS} | jq -r '.stable' 2>/dev/null)
    
    if [ -z ${LATEST_AVAILABLE_VERSION} ] || [ -z ${STABLE_AVAILABLE_VERSION} ]
    then 
        printf "FAIL to query ${URL_VERSION_CHECK}\n"
    else
        printf "latest: %s stable: %s\n" "${LATEST_AVAILABLE_VERSION}" "${STABLE_AVAILABLE_VERSION}"
    fi

    printf "Newest cached local version... "
    LATEST_LOCAL=$(find "/config/bin" -name "duplicacy_web_linux_${ARCH}_*" | sort -V | tail -1)
    if [ -z ${LATEST_LOCAL} ]
    then
        printf "None\n"
    else
        printf "%s\n" "${LATEST_LOCAL##*_}"
    fi
;;
esac

# Decide on version to use
#
case ${DUPLICACY_WEB_VERSION} in
    Stable|stable)
    DUPLICACY_WEB_VERSION=${STABLE_AVAILABLE_VERSION} 
    ;;
    Latest|latest)
    DUPLICACY_WEB_VERSION=${LATEST_AVAILABLE_VERSION} 
    ;;
esac

# If selected channel is not viable try cached one if any
#
if [ -z ${DUPLICACY_WEB_VERSION} ]
then
    if [ -z ${LATEST_LOCAL} ]
    then
        printf "No suitable duplicacy_web version determined. Cannot proceed\n"
        exit ${ERROR_NO_LOCAL_BINARY_AVAILABLE}
    fi
    DUPLICACY_WEB_VERSION=${LATEST_LOCAL##*_}
    printf "Defaulting to locally cached version ${DUPLICACY_WEB_VERSION}\n"
else
    printf "Using version ${DUPLICACY_WEB_VERSION}\n"
fi

# Target application filename and URL
#
APPFILE=duplicacy_web_linux_${ARCH}_${DUPLICACY_WEB_VERSION}
URL=${URL_DUPLICACY_WEB}/${APPFILE}
export APPFILEPATH=/config/bin/${APPFILE}

# If application executable hasn't been downloaded yet -- do it now
#
if [ ! -f ${APPFILEPATH} ]; then
    printf "Downloading executable from %s\n" "${URL}"
    wget -O ${APPFILEPATH} ${URL}
    if [[ $? != 0 ]]; then
        printf "Download failed\n"
        rm -f ${APPFILEPATH}
        exit ${ERROR_DOWNLOAD_FAILED}
    fi
    chmod +x ${APPFILEPATH}  || exit ${ERROR_CHMOD_FAILED}
else
    printf "Using cached duplicacy_web binary %s\n" "${APPFILEPATH}"
fi


# Preparing persistent unique machine ID
#
if ! dbus-uuidgen --ensure=/config/machine-id; then 
    printf "machine-id contains invalid data. Regenerating.\n"
    dbus-uuidgen > /config/machine-id
fi

printf "Using machine-id = %s\n" "$(cat /var/lib/dbus/machine-id)"

# Starting child process
#
su-exec $USR_ID:$GRP_ID launch.sh & 

child=$! 

wait "$child"
