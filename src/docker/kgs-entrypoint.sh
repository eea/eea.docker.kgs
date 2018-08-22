#!/bin/bash

echo "Fixing permissions for external /data volumes"
mkdir -vp /data/log /data/downloads/pdf /data/downloads/tmp /data/suggestions /plone/instance/src
chown -v plone:plone /data/log /data/downloads /data/downloads/pdf /data/downloads/tmp /data/suggestions /plone/instance/src

exec /plone-entrypoint.sh "$@"
