# Duplicacy-Web wrapper

This is a wrapper around http://duplicacy.com web GUI. 

Two branches are supported:

- `latest`: the classic one with the fixed version of duplicacy_web baked into the image. x86_64 only.
- `mini`: The container downloads and caches the correct binary of duplicacy_web for the host architecture and selected version on start. To update/downgrade to another version change the environment variable and restart the container. Supports x86_x64 and arm. 

Notes:

- Arm detection is untested.
- Download-on-demand approach was already used by duplicacy_web to fetch the updated version of a duplicacy cli engine. The `mini` container now extends this behavior to duplicacy_web itself making it easy to switch between versions at your cadence.

## Volumes 
`/config` -- is where configuration data will be stored. Should be backed up.

`/logs` --  logs will go there. 

`/cache` -- transient and temporary files will be stored here. Can be safely deleted.


## Environment variables 

### Duplicacy version
`ENV DUPLICACY_WEB_VERSION=1.2.1` Specifies version of duplicacy_web to use. 

With :mini tag can be modified to switch to the specified version on next start in the same container. This makes the :mini version behave more like a thin adapter layer as opposed to true self-encompassing container. 


### User
`USR_ID` and `GRP_ID` can be customized. Container will run as that user. By default user `0` (`root`) is used.

## To run
An example for appropriate volume mappings:
``` bash 
docker run  --name duplicacy-web-docker-container      \
        --hostname duplicacy-web-docker-instance       \
         --publish 3875:3875/tcp                       \
             --env USR_ID=$(id -u)                     \
             --env GRP_ID=$(id -g)                     \
             --env TZ="America/Los_Angeles"            \
          --volume ~/Library/Duplicacy:/config         \
          --volume ~/Library/Logs/Duplicacy/:/logs     \
          --volume ~/Library/Caches/Duplicacy:/cache   \
          --volume ~:/backuproot:ro                    \
                   saspus/duplicacy-web:mini 
```
Note, it's important to pass hostname, as duplicacy license is requested based on hostname and machine-id provided by dbus. Machine-id will be persisted in the /config directory.

## To use
Go to http://hostname:3875

## Source
https://bitbucket.org/saspus/duplicacy-web-docker-container
