# Sometimes PSQL craps all over itself and you can't restart it, use this instead
# https://dba.stackexchange.com/questions/75214/postgresql-not-running-on-mac

function rpsql() {
  brew services stop postgresql
	if [[ -f "/usr/local/var/postgres/postmaster.pid" ]]; then
		rm /usr/local/var/postgres/postmaster.pid
	else
		rm /opt/homebrew/var/postgres/postmaster.pid
	fi

  brew services start postgresql
}
