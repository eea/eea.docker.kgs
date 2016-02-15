FROM eeacms/www
MAINTAINER "Alin Voinea" <alin.voinea@eaudeweb.ro>

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential
USER plone

RUN buildout -c devel.cfg
