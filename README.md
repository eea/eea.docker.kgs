# EEA Plone KGS w/ EEA Add-ons ready to run Docker image

[![Build Status](https://ci.eionet.europa.eu/buildStatus/icon?job=eea/eea.docker.kgs/master)](https://ci.eionet.europa.eu/job/eea/job/eea.docker.kgs/job/master/display/redirect)
[![Pipeline Status](https://ci.eionet.europa.eu/buildStatus/icon?job=eea/eea.docker.www/master&subject=pipeline)](https://ci.eionet.europa.eu/job/eea/job/eea.docker.www/job/master/display/redirect)
[![Release](https://img.shields.io/github/release/eea/eea.docker.kgs)](https://github.com/eea/eea.docker.kgs/releases)

Docker image for Plone with EEA Common Add-ons available (formerly known as [EEA Common Plone Buildout (KGS)](https://github.com/eea/eea.plonebuildout.core)

This image is generic, thus you can obviously re-use it within
your non-related EEA projects.

## Supported tags and respective Dockerfile links

  - [Tags](https://hub.docker.com/r/eeacms/kgs/tags/)

## Base docker image

 - [hub.docker.com](https://hub.docker.com/r/eeacms/kgs/)

## Source code

  - [github.com](http://github.com/eea/eea.docker.kgs)

## Installation

1. Install [Docker](https://www.docker.com/)
2. Install [Docker Compose](https://docs.docker.com/compose/) (optional)

## Versions

* Python 2.7.12
* Plone 4.3.10
* Zope  2.13.24

## Simple Usage

    $ docker run -p 8080:8080 eeacms/kgs

Now, ask for http://localhost:8080/ in your workstation web browser and add a Plone site (default credentials `admin:admin`).

See more at [plone](https://hub.docker.com/_/plone)

## Advanced usage (ZEO, RelStorage, etc.)

Start `ZEO` server:

    $ docker run -d --name=zeo \
                 -e ZOPE_MODE=zeoserver \
             eeacms/kgs

Start 2 Plone clients:

    $ docker run -d --name=zclient1 \
                 -e ZOPE_MODE=zeo_client \
                 --link=zeo:zeoserver \
             eeacms/kgs

    $ docker run -d --name=zclient2 \
                 -e ZOPE_MODE=zeo_client \
                 --link=zeo:zeoserver \
             eeacms/kgs

Start load balancer:

    $ docker run -d --name=lb \
                 -p 8080:5000 \
                 -p 1936:1936 \
                 --link=zclient1 \
                 --link=zclient2 \
                 -e BACKENDS="zclient1 zclient2" \
                 -e BACKENDS_PORT=8080 \
                 -e DNS_ENABLED=true \
             eeacms/haproxy

Check load-balancer back-ends health at http://localhost:1936/ (default credentials `admin:admin`).
If everything looks OK go to http://localhost:8080/ and add your Plone site.

See detailed [ZEO client](https://github.com/eea/eea.docker.kgs/tree/master/examples/zeoclient/README.md) examples.

Also you can run this image as:

* [RelStorage/PostgreSQL client](https://github.com/eea/eea.docker.kgs/tree/master/examples/relstorage/README.md)
* [Development mode](https://github.com/eea/eea.docker.kgs/tree/master/examples/develop/README.md)

## Extending this image

For this you'll have to provide the following custom files:

* `buildout.cfg`
* `Dockerfile`

Below is an example of `buildout.cfg` and `Dockerfile` to build a custom version
of Plone with your custom versions of packages based on `EEA KGS` image:

**buildout.cfg**:

    [buildout]
    extends = eea.cfg

    auto-checkout =
      land.copernicus.theme
      land.copernicus.content

    [configuration]
    eggs +=
      land.copernicus.theme
      land.copernicus.content

    [sources]
    land.copernicus.theme = git https://github.com/eea/land.copernicus.theme.git
    land.copernicus.content = git https://github.com/eea/land.copernicus.content.git


**Dockerfile**:

    FROM eeacms/kgs:8.4

    COPY buildout.cfg /plone/instance/
    RUN buildout

and then run

    $ docker build -t plone-land-copernicus .


## Persist/Migrate data

* [Plone/ZEO: Where to Store Data](https://github.com/plone/plone.docker/blob/master/docs/usage.rst#8-where-to-store-data)
* [RelStorage: Persistent data as you wish](https://github.com/eea/eea.docker.postgres#persistent-data-as-you-wish)

## Upgrade

    $ docker pull eeacms/kgs


## Supported environment variables

**ZOPE:**

* `ZOPE_MODE` Can be `zeoserver`, `standalone`, `zeo_client`, `zeo_async`,  `rel_client`, `rel_async`. Default `standalone`
* `ZOPE_THREADS` Configure zserver-threads. Default `2` (e.g.: `ZOPE_THREADS=4`)
* `ZOPE_FAST_LISTEN` Set to `off` to defer opening of the HTTP socket until the end of the Zope startup phase. Defaults to `off` (e.g.: `ZOPE_FAST_LISTEN=on`)
* `ZOPE_FORCE_CONNECTION_CLOSE` Set to `on` to enforce Zope to set `Connection: close header`. Default `on` (e.g.: `ZOPE_FORCE_CONNECTION_CLOSE=off`)

**RELSTORAGE:**

* `RELSTORAGE_HOST` Custom PostgreSQL address, `postgres` by default (e.g.: `RELSTORAGE_HOST=1.2.3.4`)
* `RELSTORAGE_USER` Custom PostgreSQL user, `zope` by default (e.g.: `RELSTORAGE_USER=plone`)
* `RELSTORAGE_PASS` Custom PostgreSQL password, `zope` by default (e.g.: `RELSTORAGE_PASS=secret`)
* `RELSTORAGE_KEEP_HISTORY` history-preserving database schema, `true` by default (e.g.: `RELSTORAGE_KEEP_HISTORY=false`)

**GRAYLOG:**

* `GRAYLOG` Configure zope inside container to send logs to GrayLog. Default `logcentral.eea.europa.eu:12201`. (e.g.: `GRAYLOG=logs.example.com:12201`)
* `GRAYLOG_FACILITY` Custom GrayLog facility. Default `eea.docker.kgs` (e.g.: `GRAYLOG_FACILITY=staging.example.com`)

**SENTRY:**

* `SENTRY_DSN` Send python tracebacks to sentry.eea.europa.eu (e.g.: `SENTRY_DSN=https://<public_key>:<secret_key>@sentry.eea.europa.eu`)
* `SENTRY_SITE` ,`SERVER_NAME` Usually the application URL without scheme (e.g.: `SERVER_NAME=staging.eea.europa.eu`)
* `SENTRY_RELEASE` Your custom KGS application version (e.g: `SENTRY_RELEASE=18.5.9-2.26`)
* `SENTRY_ENVIRONMENT`, `ENVIRONMENT` Override environment. Leave empty to automatically get it from `rancher-metadata`

**CORS:**

* `CORS_ALLOW_ORIGIN` - Origins that are allowed access to the resource. Either a comma separated list of origins, for example `http://example.net,http://mydomain.com` or `*`. Defaults to `http://localhost:3000,http://127.0.0.1:3000`
* `CORS_ALLOW_METHODS` - A comma separated list of HTTP method names that are allowed by this CORS policy, for example `DELETE,GET,OPTIONS,PATCH,POST,PUT`. Defaults to `DELETE,GET,OPTIONS,PATCH,POST,PUT`
* `CORS_ALLOW_CREDENTIALS` - Indicates whether the resource supports user credentials in the request. Defaults to `true`
* `CORS_EXPOSE_HEADERS` - A comma separated list of response headers clients can access, for example `Content-Length`. Defaults to `Content-Length,X-My-Header`
* `CORS_ALLOW_HEADERS` - A comma separated list of request headers allowed to be sent by the client, for example `X-My-Header`. Defaults to `Accept,Authorization,Content-Type`
* `CORS_MAX_AGE` - Indicates how long the results of a preflight request can be cached. Defaults to `3600`



## Release new versions of this image

Get source code

    $ git clone git@github.com:eea/eea.docker.kgs.git

Update `EEA_KGS_VERSION` env within `Dockerfile`

    $ cd eea.docker.kgs
    $ vim Dockerfile

Commit changes

    $ git commit -am "Release 19.5"

Create tag

    $ git tag 19.5

Push changes

    $ git push --tags
    $ git push

Update release notes

    $ docker run -it --rm -e GIT_NAME="eea.docker.kgs" eeacms/gitflow bash
    $ /unifyChangelogs.py 19.4 19.5 2> /dev/null

Add output to https://github.com/eea/eea.docker.kgs/releases/new


## Copyright and license

The Initial Owner of the Original Code is European Environment Agency (EEA).
All Rights Reserved.

The Original Code is free software;
you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation;
either version 2 of the License, or (at your option) any later
version.

## Funding

[European Environment Agency (EU)](http://eea.europa.eu)
