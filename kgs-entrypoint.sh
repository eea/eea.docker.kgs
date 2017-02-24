#!/bin/bash
#
# Fix permissions for external volumes
#
mkdir -vp /data/downloads/pdf
mkdir -vp /data/downloads/tmp
echo "Fixing permissions: /data/downloads /plone/instance"
chown plone:plone /data/downloads /plone/instance

exec gosu plone /plone-entrypoint.sh "$@"
