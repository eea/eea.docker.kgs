#!/bin/bash
#
# Fix permissions for external volumes
#
mkdir -vp /data/downloads/pdf
mkdir -vp /data/downloads/tmp
chown -v plone:plone /plone/instance
chown -v /data/downloads
chown -v /data/downloads/pdf
chown -v /data/downloads/tmp

exec gosu plone /plone-entrypoint.sh "$@"
