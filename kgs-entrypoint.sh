#!/bin/bash
#
# Fix permissions
#
mkdir -vp /data/downloads/pdf
mkdir -vp /data/downloads/tmp
chown -vR plone:plone /data/downloads /plone

exec gosu plone /plone-entrypoint.sh "$@"
