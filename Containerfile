FROM registry.fedoraproject.org/fedora:38 AS build

COPY plex.repo /etc/yum.repos.d
RUN dnf install --assumeyes --downloadonly --destdir $(pwd) plexmediaserver

RUN mkdir package
RUN rpm2archive -n plexmediaserver-*.x86_64.rpm | tar -xC package

## fedora-minimal doesn't have user management executables installed
RUN useradd --home-dir /var/lib/plexmediaserver --system --shell /sbin/nologin plex

FROM registry.fedoraproject.org/fedora-minimal:38

COPY --from=build package/usr/lib/plexmediaserver /usr/lib/plexmediaserver
COPY --from=build /etc/passwd /etc/group /etc/

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/var/lib/plexmediaserver"
ENV PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
ENV PLEX_MEDIA_SERVER_INFO_VENDOR="Fedora Linux"
ENV PLEX_MEDIA_SERVER_INFO_PLATFORM_VERSION=38
ENV PLEX_MEDIA_SERVER_INFO_MODEL="$(uname -m)"

VOLUME /var/lib/plexmediaserver

LABEL org.label-schema.vcs-url="https://github.com/jmanero/container-image-plex"

# USER plex
ENTRYPOINT ["/usr/lib/plexmediaserver/Plex Media Server"]
