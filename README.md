# PgBouncer on Alpine Linux

Lightweight connection pooler for PostgreSQL

Read the [documentation](https://pgbouncer.github.io/usage.html) for PgBouncer before using this image.

## Configuration

This images exposes the `/etc/pgbouncer` directory as the location to store configuration. In this
folder PgBouncer expects atleast a `pgbouncer.ini` file. Depending on the content of this file two
other files usualy resides in the same location.

- databases.txt
- userlist.txt

Example `pgbouncer.ini` file:

```ini
[databases]
%include /etc/pgbouncer/databases.txt

[pgbouncer]
logfile = /var/log/pgbouncer/pgbouncer.log
pidfile = /var/run/pgbouncer/pgbouncer.pid
listen_addr = *
listen_port = 6432

ignore_startup_parameters = extra_float_digits

; any, trust, plain, crypt, md5
auth_type = trust
auth_file = /etc/pgbouncer/userlist.txt
admin_users = admin

pool_mode = session
server_reset_query = DISCARD ALL
max_client_conn = 1000
default_pool_size = 200

tcp_keepidle = 300

; TLS settings
server_tls_sslmode = prefer
server_tls_key_file = /etc/ssl/server.key
server_tls_cert_file = /etc/ssl/server.cert
server_tls_ca_file = /etc/ssl/caroot.crt
server_tls_protocol = secure
```
## TLS

The folder `/etc/ssl` is exposed as the prefered location to store SSL/TLS certs.
