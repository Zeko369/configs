function rpsql() {
  brew services stop postgresql
  rm /usr/local/var/postgres/postmaster.pid # adjust path accordingly to your install
  brew services start postgresql
}
