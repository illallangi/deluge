# confd image
FROM ghcr.io/illallangi/confd-builder:v0.0.3 AS confd

# main image
FROM docker.io/library/python:3.10.6

# install confd
COPY --from=confd /go/bin/confd /usr/local/bin/confd

# install prerequisites, deluge and plugins
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update \
  && \
  apt-get install -y --no-install-recommends \
    gosu=1.12-1+b6 \
    musl=1.2.2-1 \
  && \
  rm -rf /var/lib/apt/lists/* \
  && \
  python3 -m pip install --no-cache-dir \
    deluge==2.1.1 \
    libtorrent==2.0.6 \
    autotorrent==1.7.1 \
  && \
  curl -L https://github.com/ratanakvlun/deluge-ltconfig/releases/download/v2.0.0/ltConfig-2.0.0.egg -o /usr/local/lib/python3.10/site-packages/deluge/plugins/ltConfig-2.0.0.egg

# add local files
COPY root/ /
ENTRYPOINT ["custom-entrypoint"]
CMD ["/usr/local/bin/deluged","--config","/config","--loglevel","info","--do-not-daemonize"]
