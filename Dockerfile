# builder image - compile confd
FROM golang:1.9-alpine as confd

ARG CONFD_VERSION=0.16.0

ADD https://github.com/kelseyhightower/confd/archive/v${CONFD_VERSION}.tar.gz /tmp/

RUN apk add --no-cache \
    bzip2 \
    make && \
  mkdir -p /go/src/github.com/kelseyhightower/confd && \
  cd /go/src/github.com/kelseyhightower/confd && \
  tar --strip-components=1 -zxf /tmp/v${CONFD_VERSION}.tar.gz && \
  go install github.com/kelseyhightower/confd && \
  rm -rf /tmp/v${CONFD_VERSION}.tar.gz

# main image
FROM alpine:edge

# install confd from builder image
COPY --from=confd /go/bin/confd /usr/local/bin/confd

# install deluge from testing repo
RUN \
  echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk update && \
  apk add --upgrade apk-tools && \
  apk add --upgrade py-pip deluge@testing gosu@testing && \
  rm -rf /var/cache/apk/*

# autologin to webui
RUN \
  sed -i 's/this.passwordField.focus(true, 300)/this.onLogin()/g' /usr/lib/python3.9/site-packages/deluge/ui/web/js/deluge-all-debug.js

# add local files
COPY root/ /
ENTRYPOINT ["custom-entrypoint"]
CMD ["/usr/bin/deluged","--config","/config","--loglevel","info","--do-not-daemonize"]
