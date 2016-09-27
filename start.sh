#!/bin/sh

rm /var/run/pgbouncer/*.pid

until [ -f /etc/pgbouncer/pgbouncer.ini ]; do
     echo "waiting for config file..."
     sleep 1
done

/usr/bin/pgbouncer /etc/pgbouncer/pgbouncer.ini
