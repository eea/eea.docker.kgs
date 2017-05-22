FROM plone:4.3.10

ENV GOSU_VERSION=1.10 \
    KGS_VERSION=10.8

LABEL eea-kgs-version=$KGS_VERSION \
      maintainer="EEA: IDM2 A-Team <eea-edw-a-team-alerts@googlegroups.com>"

USER root
RUN mv /docker-entrypoint.sh /plone-entrypoint.sh
COPY docker-setup.sh docker-initialize.py kgs-entrypoint.sh docker-entrypoint.sh /
COPY src/* /tmp/
RUN /docker-setup.sh
