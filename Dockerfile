FROM alpine:3.11.11 AS builder

ARG build_tag=pgbouncer_1_15_0
ARG pandoc_tag=2.9.2.1

RUN wget https://github.com/jgm/pandoc/releases/download/${pandoc_tag}/pandoc-${pandoc_tag}-linux-amd64.tar.gz
RUN tar xvzf pandoc-${pandoc_tag}-linux-amd64.tar.gz --strip-components 1 -C /usr/local

RUN apk --no-cache add make pkgconfig autoconf automake libtool py-docutils git gcc g++ libevent-dev openssl-dev c-ares-dev ca-certificates
RUN git clone --branch ${build_tag} --recurse-submodules -j8 https://github.com/pgbouncer/pgbouncer.git

WORKDIR pgbouncer

RUN ./autogen.sh
RUN ./configure --prefix=/usr
RUN make
RUN make install

FROM alpine:3.11.11

LABEL maintainer="mikael.brorrson@gmail.com"
LABEL description="PgBouncer on Alpine Linux"

RUN apk --no-cache add libevent openssl c-ares tini

ADD start.sh /start.sh
COPY --from=builder /usr/bin/pgbouncer /usr/bin/pgbouncer
COPY --from=builder /pgbouncer/etc/pgbouncer.ini /etc/pgbouncer/pgbouncer.ini
COPY --from=builder /pgbouncer/etc/userlist.txt /etc/pgbouncer/userlist.txt

RUN \
  mkdir /var/log/pgbouncer/ /var/run/pgbouncer/ && \
  chown -R nobody:nobody /var/log/pgbouncer && \
  chown -R nobody:nobody /var/run/pgbouncer

# Healthcheck
HEALTHCHECK --interval=10s --timeout=3s CMD stat /tmp/.s.PGSQL.*

USER nobody

# VOLUME ["/etc/pgbouncer" "/etc/ssl"]

ENTRYPOINT ["tini", "--"]

EXPOSE 6432

CMD ["/start.sh"]

# pgbouncer can't run as root, so let's drop to 'nobody' by default :)
# ENTRYPOINT ["/pgbouncer/bin/pgbouncer", "-u", "nobody"]
