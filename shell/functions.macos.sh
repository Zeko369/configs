# Sometimes PSQL craps all over itself and you can't restart it, use this instead
# https://dba.stackexchange.com/questions/75214/postgresql-not-running-on-mac
function rpsql() {
  brew services stop postgresql
  rm /usr/local/var/postgres/postmaster.pid
  brew services start postgresql
}
