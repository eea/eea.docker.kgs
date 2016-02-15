# Plone w/ EEA Add-ons Docker image used as a RelStorage client

See
[docker-compose.yml](https://github.com/eea/eea.docker.kgs/blob/master/examples/relstorage/docker-compose.yml)
file for an example on how you should use
[eeacms/kgs](https://hub.docker.com/r/eeacms/kgs/)
Docker image as a RelStorage client.

## Usage

    $ git clone https://github.com/eea/eea.docker.kgs.git my-plone-deployment
    $ cd  my-plone-deployment/examples/relstorage
    $ docker-compose up -d
    $ docker-compose logs

## Upgrade

    $ cd my-plone-deployment/examples/relstorage
    $ docker-compose pull
    $ docker-compose stop
    $ docker-compose -f docker-remove.yml rm -v
    $ docker-compose up -d --no-recreate
    $ docker-compose logs

See [base image](https://github.com/eea/eea.docker.kgs) for information about this image.
