FROM alpine:latest

# Set desired duplicacy_web version or update channel and restart the container to switch to or update the version. 
# Recognized values are 
#   Latest - use latest version available as reported by https://duplicacy.com/
#	Stable - use stable version avaiobale as reported by https://duplicacy.com/
#   x.x.x  - use specific version, like 1.4.1

## Executables are cached in /config/bin

ENV DUPLICACY_WEB_VERSION=Stable

# Set to actual USR_ID and GRP_ID of the user this should run under
# Uses root by default, unless changed

ENV USR_ID=0 
ENV GRP_ID=0 

ENV TZ="America/Los_Angeles"

# Installing software
RUN apk --update add --no-cache bash ca-certificates dbus su-exec tzdata jq curl wget && \
    rm -f /var/lib/dbus/machine-id && ln -s /config/machine-id /var/lib/dbus/machine-id 

EXPOSE 3875/tcp

VOLUME /config /logs /cache

COPY ./init.sh ./launch.sh /usr/local/bin/

ENTRYPOINT /usr/local/bin/init.sh
