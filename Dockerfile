FROM alpine:latest

## Set desired duplicacy_web version and restart the container to swithc to that version. 
## Executables are cached in /config/bin

ENV DUPLICACY_WEB_VERSION=1.3.0

# Set to actual USR_ID and GRP_ID of the user this should run under
# Uses root by default, unless changed

ENV USR_ID=0 \
    GRP_ID=0 

ENV TZ="America/Los_Angeles"

# Installing software
RUN apk --update add --no-cache bash ca-certificates dbus su-exec tzdata && \
    rm -f /var/lib/dbus/machine-id && ln -s /config/machine-id /var/lib/dbus/machine-id 

EXPOSE 3875/tcp
VOLUME /config /logs /cache

COPY ./init.sh ./launch.sh /usr/local/bin/

ENTRYPOINT /usr/local/bin/init.sh
