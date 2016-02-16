# EEA Plone KGS w/ EEA Add-ons ready to run Docker image

Docker image for Plone with EEA Common Add-ons available based on
[EEA Common Plone Buildout](https://github.com/eea/eea.plonebuildout.core)

This image is generic, thus you can obviously re-use it within
your non-related EEA projects.

### Supported tags and respective Dockerfile links

  - [Tags](https://hub.docker.com/r/eeacms/kgs/tags/)

These tags have nothing to do with Plone version. They refer to the
[EEA KGS versions](https://github.com/eea/eea.plonebuildout.core/tree/master/buildout-configs/kgs).
The used Plone version can be found within Dockerfile used to create this image.

### Base docker image

 - [hub.docker.com](https://hub.docker.com/r/eeacms/kgs/)

### Source code

  - [github.com](http://github.com/eea/eea.docker.kgs)

### Installation

1. Install [Docker](https://www.docker.com/)
2. Install [Docker Compose](https://docs.docker.com/compose/) (optional)

### Versions

* Plone 4.3.7
* Zope  2.13.23

## Usage

    $ docker run -p 8080:8080 eeacms/kgs

See more at [eeacms/plone](https://github.com/eea/eea.docker.plone)

Also you can also run this image as:

* [ZEO client](https://github.com/eea/eea.docker.kgs/tree/master/examples/zeoclient/README.md)
* [RelStorage/PostgreSQL client](https://github.com/eea/eea.docker.kgs/tree/master/examples/relstorage/README.md)
* [Development mode](https://github.com/eea/eea.docker.kgs/tree/master/examples/develop/README.md)

### Extend the image with custom buildout configuration files

For this you have the possibility to override:

* `buildout.cfg`

Below is an example of `buildout.cfg` and `Dockerfile` to build a custom version
of Plone with your custom versions of packages based on this image:

**buildout.cfg**:

    [buildout]
    extends = eea.cfg

    auto-checkout =
      land.copernicus.content

    [instance]
    eggs +=
      land.copernicus.theme
      land.copernicus.content

    [versions]
    land.copernicus.theme = 1.7

    [sources]
    land.copernicus.content = git https://github.com/eea/land.copernicus.content.git

**Dockerfile**:

    FROM eeacms/kgs:6.0

    COPY buildout.cfg /plone/instance/
    RUN buildout

and then run

    $ docker build -t copernicus:6.0 .


## Persist/Migrate data

* [Plone: Persistent data as you wish](https://github.com/eea/eea.docker.plone#persistent-data-as-you-wish)
* [ZEO: Persistent data as you wish](https://github.com/eea/eea.docker.zeoserver#persistent-data-as-you-wish)
* [RelStorage: Persistent data as you wish](https://github.com/eea/eea.docker.postgres#persistent-data-as-you-wish)

## Upgrade

    $ docker pull eeacms/kgs


## Release new versions of this image

Get source code

    $ git clone git@github.com:eea/eea.docker.kgs.git

Update `KGS_VERSION` env within `Dockerfile`

    $ cd eea.docker.kgs
    $ vim Dockerfile

Commit changes

    $ git commit -a "Release 19.5"

Create tag

    $ git tag 19.5

Push changes

    $ git push
    $ git push --tags


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
