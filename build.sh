#!/usr/bin/env bash
set -ex

## Lookup the latest Plex Media Server release version, artifact, and checksum
curl -v https://plex.tv/api/downloads/5.json | jq '.computer.Linux.releases[] | select(.distro == "redhat" and .build == "linux-x86_64")' >release.json

ARTIFACT_URL=$(jq -r '.url' <release.json)
ARTIFACT_CHECKSUM=$(jq -r '.checksum' <release.json)
FULL_VERSION=$(jq -r .version <release.json)
VERSION=$(jq -r .version <release.json | cut -d. -f1-3)
MAJOR_MINOR_VERSION=$(jq -r .version <release.json | cut -d. -f1-2)
GIT_REF=${1:-head}
GIT_SHORT=$(git rev-parse --short $GIT_REF)
TIMESTAMP=$(date --utc +%Y-%m-%dT%H%M%S)

docker build --pull --file Containerfile\
  --build-arg "VERSION=$VERSION"\
  --build-arg "ARTIFACT_URL=$ARTIFACT_URL"\
  --build-arg "ARTIFACT_CHECKSUM=$ARTIFACT_CHECKSUM"\
  --label "org.opencontainers.image.revision=$GIT_REF" \
  --label "org.opencontainers.image.version=$FULL_VERSION" \
  --tag ghcr.io/jmanero/plex:latest .

docker tag ghcr.io/jmanero/plex:latest "ghcr.io/jmanero/plex:$MAJOR_MINOR_VERSION"
docker tag ghcr.io/jmanero/plex:latest "ghcr.io/jmanero/plex:$VERSION"
docker tag ghcr.io/jmanero/plex:latest "ghcr.io/jmanero/plex:$FULL_VERSION"
docker tag ghcr.io/jmanero/plex:latest "ghcr.io/jmanero/plex:$VERSION-git.$GIT_SHORT"
docker tag ghcr.io/jmanero/plex:latest "ghcr.io/jmanero/plex:$VERSION-git.$GIT_SHORT-$TIMESTAMP"

docker push "ghcr.io/jmanero/plex:$VERSION-git.$GIT_SHORT-$TIMESTAMP"
docker push "ghcr.io/jmanero/plex:$VERSION-git.$GIT_SHORT"
docker push "ghcr.io/jmanero/plex:$FULL_VERSION"
docker push "ghcr.io/jmanero/plex:$VERSION"
docker push "ghcr.io/jmanero/plex:$MAJOR_MINOR_VERSION"
docker push ghcr.io/jmanero/plex:latest
