#!/bin/sh

function readPkg {
  FILE=./package.json
  if [ ! -f "$FILE" ]; then
    echo "Can't find package.json"
    return 1
  fi

  if ! command -v jq &> /dev/null; then
    FIRST_LINE=$(cat $FILE | grep -n "\"$KEY\": {" | cut -f1 -d:)
    OFFSET=$(tail -n +$FIRST_LINE $FILE | grep -n "}" | head -n 1 | cut -f1 -d:)
    LAST_LINE="$(($FIRST_LINE + $OFFSET - 2))"

    sed -n "$(($FIRST_LINE +1)),$LAST_LINE"p $FILE | awk '$1=$1'
  else
    select="{$KEY} | .[\"$KEY\"]"
    cat $FILE | jq $select
  fi
}

# List yarn scripts from package.json
function scripts {
  KEY="scripts"
  readPkg
}

function scriptsSimple {
	if ! command -v jq &> /dev/null; then
		echo "This requires jq, you can use regular scripts without jq"
	else
		
	fi
}

function packages {
  if [ $# -eq 1 ]; then
    KEY="devDependencies"
    readPkg
  else
    KEY="dependencies"
    readPkg
  fi
}

function venvinit() {
  if [ $# -eq 0 ]; then
      python3 -m venv ./venv
  else
      python3 -m venv $1
  fi 
}
