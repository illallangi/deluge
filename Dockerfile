# builder image - compile confd
FROM golang:1.9-alpine as confd

ARG CONFD_VERSION=0.16.0

ADD https://github.com/kelseyhightower/confd/archive/v${CONFD_VERSION}.tar.gz /tmp/

RUN \
  apk add --no-cache \
    bzip2 \
    make && \
  mkdir -p /go/src/github.com/kelseyhightower/confd && \
  cd /go/src/github.com/kelseyhightower/confd && \
  tar --strip-components=1 -zxf /tmp/v${CONFD_VERSION}.tar.gz && \
  go install github.com/kelseyhightower/confd && \
  rm -rf /tmp/v${CONFD_VERSION}.tar.gz

# main image
FROM debian:latest

# install confd from builder image
COPY --from=confd /go/bin/confd /usr/local/bin/confd

# install prerequisites
RUN \
  apt-get update \
  && \
  apt-get install -y \
    build-essential \
    curl \
    gdb \
    git \
    gosu \
    libboost-dev \
    libboost-python-dev \
    libboost-system-dev \
    libboost-tools-dev \
    libssl-dev \
    musl \
    python3 \
    python3-dev \
    python3-pip \
  && \
  apt-get clean

# install libtorrent
RUN \
  curl \
    --location https://github.com/arvidn/libtorrent/releases/download/v2.0.5/libtorrent-rasterbar-2.0.5.tar.gz | \
  tar \
    --extract \
    --directory /usr/local/src \
    --gzip \
    --verbose \
  && \
  cd /usr/local/src/libtorrent-rasterbar-2.0.5 \
  && \
  python3 setup.py build_ext --b2-args="cxxstd=14 lto=on dht=on crypto=openssl debug-symbols=on" install \
  && \
  cd \
  && \
  rm -rfv /usr/local/src/libtorrent-rasterbar-2.0.5

# install deluge
RUN \
  git clone git://deluge-torrent.org/deluge.git /usr/local/src/deluge \
  && \
  python3 -m pip install /usr/local/src/deluge \
  && \
  rm -rfv /usr/local/src/deluge

# autologin to webui
RUN \
  sed -i 's/this.passwordField.focus(true, 300)/this.onLogin()/g' /usr/local/lib/python3.9/dist-packages/deluge/ui/web/js/deluge-all-debug.js

# install autotorrent
RUN \
  python3 -m pip install autotorrent

# add local files
COPY root/ /
ENTRYPOINT ["custom-entrypoint"]
CMD ["/usr/local/bin/deluged","--config","/config","--loglevel","info","--do-not-daemonize"]
