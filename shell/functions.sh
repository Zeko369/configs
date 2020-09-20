#!/bin/sh

# Sometimes PSQL craps all over itself and you can't restart it, use this instead
# https://dba.stackexchange.com/questions/75214/postgresql-not-running-on-mac
function rpsql() {
  brew services stop postgresql
  rm /usr/local/var/postgres/postmaster.pid
  brew services start postgresql
}

# List yarn scripts from package.json
function scripts() {
  FILE=./package.json
  if [ ! -f "$FILE" ]; then
    echo "Can't find package.json"
    return 1
  fi

  if ! command -v jq &> /dev/null; then
    FIRST_LINE=$(cat $FILE | grep -n "\"scripts\": {" | cut -f1 -d:)
    OFFSET=$(tail -n +$FIRST_LINE $FILE | grep -n "}" | head -n 1 | cut -f1 -d:)
    LAST_LINE="$(($FIRST_LINE + $OFFSET - 2))"

    sed -n "$(($FIRST_LINE +1)),$LAST_LINE"p $FILE | awk '$1=$1'
  else
    cat $FILE | jq '{scripts} | .["scripts"]'
  fi
}