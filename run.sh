#!/usr/bin/sh -ex

rm -f "${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR}/Plex Media Server/plexmediaserver.pid"
exec "/usr/lib/plexmediaserver/Plex Media Server"
