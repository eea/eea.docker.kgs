#!/bin/bash

echo "Fixing permissions for external /data volumes"
mkdir -vp /data/downloads/pdf /data/downloads/tmp /data/suggestions
chown -v plone:plone /data/downloads /data/downloads/pdf /data/downloads/tmp /data/suggestions

exec gosu plone /plone-entrypoint.sh "$@"
