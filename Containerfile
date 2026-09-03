FROM registry.fedoraproject.org/fedora:latest AS build

ARG VERSION
ARG ARTIFACT_URL
ARG ARTIFACT_CHECKSUM

RUN curl -v -O "$ARTIFACT_URL"
RUN echo "$ARTIFACT_CHECKSUM $(basename $ARTIFACT_URL)" >checksum
RUN sha1sum -c checksum

RUN mkdir package
RUN rpm2archive -n "$(basename $ARTIFACT_URL)" | tar -xC package

## fedora-minimal doesn't have user management executables installed
RUN useradd --home-dir /var/lib/plexmediaserver --system --shell /sbin/nologin plex

FROM registry.fedoraproject.org/fedora-minimal:latest

COPY --from=build package/usr/lib/plexmediaserver /usr/lib/plexmediaserver
COPY --from=build /etc/passwd /etc/group /etc/
COPY --chmod=0755 run.sh /usr/bin

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/var/lib/plexmediaserver"
ENV PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
ENV PLEX_MEDIA_SERVER_INFO_VENDOR="Fedora Linux"
ENV PLEX_MEDIA_SERVER_INFO_MODEL="$(uname -m)"

VOLUME /var/lib/plexmediaserver

LABEL org.opencontainers.image.authors="John Manero <https://github.com/jmanero>"
LABEL org.opencontainers.image.url="https://github.com/jmanero/container-image-plex"
LABEL org.opencontainers.image.title="Plex Media Server"
LABEL org.opencontainers.image.description="Plex Media Server on a Fedora minimal base image"

# USER plex
ENTRYPOINT ["/usr/bin/run.sh"]
