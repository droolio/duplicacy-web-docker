#!/usr/bin/env bash

readonly ERROR_UNSUPPORTED_ARCHITECTURE=1
readonly ERROR_NO_LOCAL_BINARY_AVAILABLE=2
readonly ERROR_DOWNLOAD_FAILED=3
readonly ERROR_CHMOD_FAILED=4
readonly ERROR_DOWNLOADED_HASH_MISMATCH=5

readonly URL_VERSION_CHECK='https://duplicacy.com/latest_web_version'
readonly URL_DUPLICACY_WEB='https://acrosync.com/duplicacy-web'

function terminator() { 
  echo 
  echo "Terminating pid $child...." 
  kill -TERM "$child" 2>/dev/null
  echo "Exiting."
}

trap terminator SIGHUP SIGINT SIGQUIT SIGTERM
echo "init.sh is running as user $(id -un):$(id -gn)\($(id -u):$(id -g)\)"

# Overhauling userbase
#
echo "root:x:0:root" > /etc/group
echo "root:x:0:0:root:/root:/bin/ash" > /etc/passwd
if [ "$GRP_ID" -ne 0 ]; then
    addgroup -g "$GRP_ID" -S duplicacy;
fi
if [ "$USR_ID" -ne 0 ]; then
    adduser -u "$USR_ID" -S duplicacy -G duplicacy;
fi
 
# Configuring folders and permissions   
# 
mkdir -p                        /config/bin /logs /cache
chown -R "$USR_ID":"$GRP_ID"    /config     /logs /cache

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
aarch64)
    ARCH=arm64
    ;;
*)
    echo Unknown or unsupported architecture "${MACHINE_ARCH}"
    exit ${ERROR_UNSUPPORTED_ARCHITECTURE}
    ;;
esac

# Determine available versions for Latest and Stable channels: 
#
case ${DUPLICACY_WEB_VERSION} in
Stable|Latest|stable|latest)
    printf "Remote available versions... " 
    AVAILABLE_VERSIONS=$(curl -s ${URL_VERSION_CHECK})
    LATEST_AVAILABLE_VERSION=$(echo "${AVAILABLE_VERSIONS}" | jq -r '.latest' 2>/dev/null)
    STABLE_AVAILABLE_VERSION=$(echo "${AVAILABLE_VERSIONS}" | jq -r '.stable' 2>/dev/null)
    
    if [ -z "${LATEST_AVAILABLE_VERSION}" ] || [ -z "${STABLE_AVAILABLE_VERSION}" ]
    then 
        printf "FAIL to query %s\n" ${URL_VERSION_CHECK}
    else
        printf "latest: %s stable: %s\n" "${LATEST_AVAILABLE_VERSION}" "${STABLE_AVAILABLE_VERSION}"
    fi

    printf "Newest cached local version... "
    LATEST_LOCAL=$(find "/config/bin" -name "duplicacy_web_linux_${ARCH}_*" | sort -V | tail -1)
    if [ -z "${LATEST_LOCAL}" ]
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
if [ -z "${DUPLICACY_WEB_VERSION}" ]
then
    if [ -z "${LATEST_LOCAL}" ]
    then
        printf "No suitable duplicacy_web version determined. Cannot proceed\n"
        exit ${ERROR_NO_LOCAL_BINARY_AVAILABLE}
    fi
    DUPLICACY_WEB_VERSION=${LATEST_LOCAL##*_}
    printf "Defaulting to locally cached version %s\n" "${DUPLICACY_WEB_VERSION}"
else
    printf "Using version %s\n" "${DUPLICACY_WEB_VERSION}"
fi

# Target application filename and URL
#
APP_FILE=duplicacy_web_linux_${ARCH}_${DUPLICACY_WEB_VERSION}
URL=${URL_DUPLICACY_WEB}/${APP_FILE}
export APP_FILE_PATH=/config/bin/${APP_FILE}

# If application executable hasn't been downloaded yet -- do it now
#
if [ ! -f "${APP_FILE_PATH}" ]; then
    printf "Downloading executable from %s\n" "${URL}"
    wget -O "${APP_FILE_PATH}" "${URL}"
    outcome=$?
    if [ $outcome -ne 0 ]; then
        printf "Download failed. Deleting partial download %s and exiting\n" "$APP_FILE_PATH"
        rm -f "${APP_FILE_PATH}"
        exit ${ERROR_DOWNLOAD_FAILED}
    fi

    HASH=$(curl -s ${URL_VERSION_CHECK} | jq -r ".hashes.\"${DUPLICACY_WEB_VERSION}\".linux_${ARCH}" 2>/dev/null)
    if [ -n "$HASH" ] && [ "$HASH" != "null" ]; then
        read -r ACTUAL_HASH _ <<< "$(sha256sum -b "${APP_FILE_PATH}")"
        if [ "$HASH" != "$ACTUAL_HASH" ]; then
            printf "Downloaded file hash differs from the expected.\n"
            printf "Web service reports hash value of %s.\n" "${HASH}"
            printf "Downloaded executable has a hash value of %s.\n" "$ACTUAL_HASH"
            printf "Cannot proceed. Deleting the executable %s and exiting.\n" "$APP_FILE_PATH"
            rm -f "${APP_FILE_PATH}"
            exit ${ERROR_DOWNLOADED_HASH_MISMATCH}
        else
            printf "Hash of the downloaded executable matches the expected value "
            printf "for binary linux_%s, version %s: %s\n" "$ARCH" "$DUPLICACY_WEB_VERSION" "$HASH"
        fi
    else
        printf "\nCannot verify validify of the downloaded executable: "
        printf "could not get expected hash value from the web service at %s " "$URL_VERSION_CHECK"
        printf "for the linux_%s binary of version %s\n" "$ARCH" "$DUPLICACY_WEB_VERSION"
        printf "\n***Proceeding anyway***.\n\n"
    fi

    chmod +x "${APP_FILE_PATH}"  || exit ${ERROR_CHMOD_FAILED}
else
    printf "Using cached duplicacy_web binary %s\n" "${APP_FILE_PATH}"
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
su-exec "$USR_ID":"$GRP_ID" launch.sh &

child=$! 

wait "$child"
