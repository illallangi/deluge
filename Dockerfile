# main image
FROM docker.io/library/python:3.10.3

# install confd
COPY --from=ghcr.io/illallangi/confd-builder:v0.0.1 /go/bin/confd /usr/local/bin/confd


# install prerequisites
RUN \
  apt-get update \
  && \
  apt-get install -y \
    gosu \
    musl \
  && \
  apt-get clean

# install deluge
RUN \
  python3 -m pip install \
    deluge==2.0.5 \
    libtorrent==2.0.5 \
    autotorrent

RUN \
  curl -L https://github.com/ratanakvlun/deluge-ltconfig/releases/download/v2.0.0/ltConfig-2.0.0.egg -o /usr/local/lib/python3.10/site-packages/deluge/plugins/ltConfig-2.0.0.egg

# # autologin to webui
# RUN \
#   sed -i 's/this.passwordField.focus(true, 300)/this.onLogin()/g' /usr/local/lib/python3.9/dist-packages/deluge/ui/web/js/deluge-all-debug.js

# add local files
COPY root/ /
ENTRYPOINT ["custom-entrypoint"]
CMD ["/usr/local/bin/deluged","--config","/config","--loglevel","info","--do-not-daemonize"]
