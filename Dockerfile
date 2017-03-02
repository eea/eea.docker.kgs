FROM plone:4.3.10
MAINTAINER "EEA: IDM2 A-Team" <eea-edw-a-team-alerts@googlegroups.com>

ENV GOSU_VERSION=1.10 \
    ZC_BUILDOUT=2.5.1 \
    SETUPTOOLS=20.9.0 \
    KGS_VERSION=9.5

USER root
RUN mv /docker-entrypoint.sh /plone-entrypoint.sh
COPY docker-setup.sh docker-initialize.py kgs-entrypoint.sh docker-entrypoint.sh /
COPY src/* /tmp/
RUN /docker-setup.sh
