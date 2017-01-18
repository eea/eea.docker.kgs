#!/bin/bash
#
# Fix permissions for external volumes
#
mkdir -vp /data/downloads/pdf
mkdir -vp /data/downloads/tmp
chown -vR plone:plone /data/downloads

exec gosu plone /plone-entrypoint.sh "$@"
