# main image
FROM docker.io/library/python:3.10.15

# install prerequisites, confd, deluge and plugins
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update \
  && \
  if [ "$(uname -m)" = "aarch64" ]; then \
    curl https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-arm64 --location --output /usr/local/bin/confd \
    ; fi \
  && \
  if [ "$(uname -m)" = "x86_64" ]; then \
    curl https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 --location --output /usr/local/bin/confd \
    ; fi \
  && \
  apt-get install -y --no-install-recommends \
    gosu=1.14-1+b10 \
    musl=1.2.3-1 \
    tree=2.1.0-1 \
  && \
  rm -rf /var/lib/apt/lists/* \
  && \
  python3 -m pip install --no-cache-dir \
    deluge==2.1.1 \
    libtorrent==2.0.9 \
    autotorrent==1.7.1 \
  && \
  curl -L https://github.com/ratanakvlun/deluge-ltconfig/releases/download/v2.0.0/ltConfig-2.0.0.egg -o /usr/local/lib/python3.10/site-packages/deluge/plugins/ltConfig-2.0.0.egg \
  && \
  chmod +x \
    /usr/local/bin/confd

# add local files
COPY root/ /
ENTRYPOINT ["custom-entrypoint"]
CMD ["/usr/local/bin/deluged","--config","/config","--loglevel","info","--do-not-daemonize"]
