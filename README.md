Container Image: Plex Media Server
==================================

[Plex Media Server](https://www.plex.tv/personal-media-server/) in a Fedora 38 (minimal) based container image without systemd.

## Building

```
docker build -f Containerfile .
```

## Usage

```
docker run -d --net host --volume $APPDATA:/var/lib/plexmediaserver --volume $LIBRARY:/library ghcr.io/jmanero/plex
```

By default, the `Plex Media Server` process runs as root in the container. The image includes a `plex` user with a system UID/GID; add `-u plex` to `docker run` commands to run the service without root privileges.

The current image build _should_ provision a `plex` user with a UID and GID of 999/999. This can be verified with the following:

```
% docker run --rm --pull always --user plex --entrypoint id ghcr.io/jmanero/plex
uid=999(plex) gid=999(plex) groups=999(plex)
```
