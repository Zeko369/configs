#!/bin/sh

# https://dba.stackexchange.com/questions/75214/postgresql-not-running-on-mac

brew services stop postgresql
rm /usr/local/var/postgres/postmaster.pid # adjust path accordingly to your install
brew services start postgresql
