#!/bin/bash
set -e

cd /plone/instance
if [ ! -z "$GIT_NAME" ]; then
  if [ ! -z "$GIT_BRANCH" ]; then
    cd src/$GIT_NAME
    if [ ! -z "$GIT_CHANGE_ID" ]; then
       git fetch origin pull/$GIT_CHANGE_ID/head:$GIT_BRANCH
    fi
    git checkout $GIT_BRANCH
    cd ../..
    sed -i "s|^$GIT_NAME .*$|$GIT_NAME = fs $GIT_NAME|g" sources.cfg
  fi
fi
bin/develop rb
python /docker-initialize.py

if [ -z "$1" ]; then
  echo "============================================================="
  echo "All set. Now you can dive into container and start debugging:"
  echo "                                                             "
  echo "    $ docker exec -it <container_name_or_id> bash            "
  echo "    $ ps aux                                                 "
  echo "    $ bin/instance fg                                        "
  echo "                                                             "
  echo "============================================================="
  exec cat
fi

if [ "$1" == "tests" ]; then
 for i in $(ls src); do

   # Auto exclude tests
   if ! grep -q "$i" bin/test; then
       echo "============================================================="
       echo "Auto: Skipping tests for: $i                                 "
       continue
   fi

   # Manual exclude tests
   if [ ! -z "$EXCLUDE" ]; then
     if [[ $EXCLUDE == *"$i"* ]]; then
       echo "============================================================="
       echo "Manual: Skipping tests for: $i                               "
       continue
     fi
   fi

   # Run tests
   echo "============================================================="
   echo "Running tests for:                                           "
   echo "                                                             "
   echo "    $i                                                       "
   echo "                                                             "

   ./bin/test --test-path /plone/instance/src/$i -v -vv -s $i
  done
else
  exec "$@"
fi

