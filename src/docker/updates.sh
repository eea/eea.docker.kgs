#!/bin/bash

# Store and inform revision via hidden file

FILENAME="/plone/instance/.current_revision"

json=$(curl https://api.github.com/repos/eea/eea.docker.kgs/commits/HEAD 2> /dev/null)
open=0
buffer=""
for (( i=0; i<${#json}; i++ )); do
    char=${json:$i:1}
    if [ "$char" = "{" ]; then
        open=$(( $open+1 ))
        testdone=$( echo $buffer | grep '"sha":"[a-f0-9]\+"' )
        if [ -n "$testdone" ]; then
            break
        fi
    elif [ "$char" = "}" ]; then
        open=$(( $open-1 ))
        testdone=$( echo $buffer | grep '"sha":"[a-f0-9]\+"' )
        if [ -n "$testdone" ]; then
            break
        fi
    elif [ "$open" = "1" ]; then
        if [ "$char" != $'\n' -a "$char" != " " ]; then
            buffer="$buffer$char"
        fi
    fi
done

LATEST=$( echo $buffer | sed 's/"sha":"\([a-f0-9]\+\)".*/\1/' )
if [ -z "$LATEST" ]; then
    echo "Fatal: Can not read last revision of eea.docker.kgs"
    exit 1
fi

echo $LATEST > $FILENAME

