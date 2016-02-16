# Plone w/ EEA Add-ons Docker image (development mode)

Below is an example of
[docker-compose.yml](https://github.com/eea/eea.docker.kgs/blob/master/develop/docker-compose.yml)
file that will allow you to run Plone within a Docker container and still
be able to test and develop your Plone add-ons using your favorite editor/IDE:

## Usage

    $ git clone https://github.com/eea/eea.docker.kgs.git my-plone-deployment
    $ cd  my-plone-deployment/examples/develop    

Update source code:

    $ docker-compose up source_code

Start:

    $ docker-compuse up -d plone

## Debug

As you can not directly add `pdb` anymore within your code, you'll have to use `rpdb`.

Add rpdb breakpoint:

    import rpdb; rpdb.set_trace("0.0.0.0")

Restart Plone container:

    $ docker-compose restart plone
    $ docker-compose logs plone

You'll get something like this within logs when the breakpoint is reached:

    plone_1 | pdb is running on 0.0.0.0:4444

Find your host ip:

    $ ip addr | grep "inet 10" | gawk '{print $2}' | sed "s/\/24//g"

This will return something like:

    10.1.2.3

And now start debugging (replace `10.1.2.3` with your ip address):

    nc 10.1.2.3 4444
