#!/bin/bash
#
# Fix permissions for external volumes
#
mkdir -vp /data/downloads/pdf
mkdir -vp /data/downloads/tmp
chown -v plone:plone /plone/instance
chown -v plone:plone /data/downloads
chown -v plone:plone /data/downloads/pdf
chown -v plone:plone /data/downloads/tmp

exec gosu plone /plone-entrypoint.sh "$@"
