# Duplicacy-Web wrapper

This is a wrapper around http://duplicacy.com web GUI. 

Two branches are supported:

- `latest`: the classic one with the fixed version of duplicacy_web baked into the image.
- `mini`: The container downloads and caches the correct binary of duplicacy_web for the host architecture and selected version on start. To update/downgrade to another version change the environment variable and restart the container.

Supports x64, arm, arm64.

Notes:

- Download-on-demand approach was already used by duplicacy_web to fetch the updated version of a duplicacy cli engine. The `mini` container now extends this behavior to duplicacy_web itself making it easy to switch between versions at your cadence.

## Volumes 
`/config` -- is where configuration data will be stored. Should be backed up.

`/logs` --  logs will go there. 

`/cache` -- transient and temporary files will be stored here. Can be safely deleted.


## Environment variables 
### Common variables
`USR_ID` and `GRP_ID`: User and group ID under which the duplicacy_web will be running.

`TZ`: time zone. Refer to https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

`USR_ID` and `GRP_ID` can be customized. Container will run as that user. By default user `0` (`root`) is used.

### `:mini` only
`DUPLICACY_WEB_VERSION`: Specifies version of duplicacy_web to fetch and use. 

Acceptable values:

- `x.x.x` - Use specific version, like 1.4.1
- `Latest` - Use latest available version from Acrosync.
- `Stable` - Use last known stable version as [defined](https://forum.duplicacy.com/t/how-to-find-out-the-url-for-the-latest-version-of-web-gui-and-or-check-for-update/4183/12?u=saspus) by Acrosync.

To apply the changes restart the container. When on Latest or Stabe channels restart the container to check for and apply updates as needed. This makes the `:mini` version behave more like a thin adapter layer as opposed to true self-encompassing container. 


## To run

An example for `:mini` branch; the duplicacy_web version is selectable via environment variable:
``` bash 
docker run  --name duplicacy-web-docker-container         \
        --hostname duplicacy-web-docker-instance          \
         --publish 3875:3875/tcp                          \
             --env USR_ID=$(id -u)                        \
             --env GRP_ID=$(id -g)                        \
             --env TZ="America/Los_Angeles"               \
             --env DUPLICACY_WEB_VERSION="Stable"         \
          --volume ~/Library/Duplicacy:/config            \
          --volume ~/Library/Logs/Duplicacy/:/logs        \
          --volume ~/Library/Caches/Duplicacy:/cache      \
          --volume ~:/backuproot:ro                       \
                   saspus/duplicacy-web:mini 
```

An example for `:latest` branch; the duplicacy_web version is baked into the container:
``` bash 
docker run  --name duplicacy-web-docker-container         \
        --hostname duplicacy-web-docker-instance          \
         --publish 3875:3875/tcp                          \
             --env USR_ID=$(id -u)                        \
             --env GRP_ID=$(id -g)                        \
             --env TZ="America/Los_Angeles"               \
          --volume ~/Library/Duplicacy:/config            \
          --volume ~/Library/Logs/Duplicacy/:/logs        \
          --volume ~/Library/Caches/Duplicacy:/cache      \
          --volume ~:/backuproot:ro                       \
                   saspus/duplicacy-web:latest 
```


Notes:

1. It's important to pass a hostname, as duplicacy license is requested based on hostname and machine-id provided by dbus. Machine-id will be persisted in the /config directory.
2. To perform backups and other maintenance tasks it's sufficient (and recommended) to mount the source read-only (see `~:/backuproot:ro` above), however in order for the restore to succeed the target volume needs to be mounted in RW mode. 

## To use
Go to http://hostname:3875

## Source
https://bitbucket.org/saspus/duplicacy-web-docker-container
