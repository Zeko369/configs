## PSQL

When upgrading psql via brew do `brew postgresql-upgrade-database`

Start it with this to easier catch errors

```
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
```
