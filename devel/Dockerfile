FROM eeacms/kgs
MAINTAINER "EEA: IDM2 A-Team" <eea-edw-a-team-alerts@googlegroups.com>

COPY devel.cfg /plone/instance/
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential \
 && rm -vrf /var/lib/apt/lists/* \
 && buildout -c devel.cfg
