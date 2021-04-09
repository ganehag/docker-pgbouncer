FROM alpine:3.11

ENV PGBOUNCER_VERSION 1.14.0

LABEL "maintainer" "mikael.brorsson@gmail.com"

RUN apk --update --no-cache --virtual build-dependencies add \
  autoconf \
  autoconf-doc \
  automake \
  c-ares \
  c-ares-dev \
  curl \
  gcc \
  libc-dev \
  libevent \
  libevent-dev \
  libtool \
  make \
  man \
  openssl-dev \
  pkgconfig

RUN \
  apk --no-cache add libevent c-ares libssl1.1 libcrypto1.1 tini && \
  \
  \
  echo "=======> download source" && \
  curl -o  /tmp/pgbouncer-${PGBOUNCER_VERSION}.tar.gz -L https://pgbouncer.github.io/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz && \
  cd /tmp && \
  tar xvfz /tmp/pgbouncer-${PGBOUNCER_VERSION}.tar.gz && \
  cd pgbouncer-${PGBOUNCER_VERSION} && \
  ./configure --prefix=/usr && \
  make && \
  cp pgbouncer /usr/bin && \
  mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer && \
  cp etc/pgbouncer.ini /etc/pgbouncer/ && \
  cp etc/userlist.txt /etc/pgbouncer/ && \
  adduser -D -S pgbouncer && \
  chown pgbouncer /var/run/pgbouncer && \
  cd /tmp && \
  rm -rf /tmp/pgbouncer*  && \
  sed -i 's/logfile = \/var\/log\/pgbouncer\/pgbouncer.log/; logfile = \/var\/log\/pgbouncer\/pgbouncer.log/' /etc/pgbouncer/pgbouncer.ini && \
  apk del --purge build-dependencies && \
  mkdir -p /var/log/pgbouncer && \
  mkdir -p /var/run/pgbouncer && \
  touch /var/log/pgbouncer/pgbouncer.log && \
  chown -R pgbouncer /var/run/pgbouncer && \
  chown -R pgbouncer /var/log/pgbouncer 

ADD start.sh /start.sh

USER pgbouncer

VOLUME ["/etc/pgbouncer" "/etc/ssl"]

ENTRYPOINT ["tini", "--"]

EXPOSE 6432

CMD ["/start.sh"]
