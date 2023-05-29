# toolbx image
FROM ghcr.io/illallangi/toolbx:v0.0.13 as toolbx

# main image
FROM docker.io/library/python:3.10.7

# install confd
COPY --from=toolbx /usr/local/bin/confd /usr/local/bin/confd

# install prerequisites, deluge and plugins
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update \
  && \
  if [ "$(uname -m)" = "aarch64" ]; then \
    apt-get install -y --no-install-recommends \
      gosu=1.12-1+b6 \
      musl=1.2.2-1 \
      tree=1.8.0-1 \
    ; fi \
  && \
  if [ "$(uname -m)" = "x86_64" ]; then \
    apt-get install -y --no-install-recommends \
      gosu=1.12-1+b6 \
      musl=1.2.2-1 \
      tree=1.8.0-1+b1 \
    ; fi \
  && \
  rm -rf /var/lib/apt/lists/* \
  && \
  python3 -m pip install --no-cache-dir \
    deluge==2.1.1 \
    libtorrent==2.0.9 \
    autotorrent==1.7.1 \
  && \
  curl -L https://github.com/ratanakvlun/deluge-ltconfig/releases/download/v2.0.0/ltConfig-2.0.0.egg -o /usr/local/lib/python3.10/site-packages/deluge/plugins/ltConfig-2.0.0.egg

# add local files
COPY root/ /
ENTRYPOINT ["custom-entrypoint"]
CMD ["/usr/local/bin/deluged","--config","/config","--loglevel","info","--do-not-daemonize"]
