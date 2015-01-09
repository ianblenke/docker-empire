## ianblenke/empire

This is a docker image for [empire](http://www.wolfpackempire.com/) built from the sourceforge [empserver](https://empserver.sf.net) source

A quick example of running this image:

    docker run -d --name empire -p 3000:3000 -p 6665:6665 ianblenke/empire

The wetty web port is 3000, and the empserver protocol port is 6665 for empire clients to connect to remotely (not necessary for wetty based single-container deployment).

Passing an ECONFIG environment variable in key=value,key2=value,... format will generate an empire econfig file.

If an /empserver/newcap_script doesn't yet exist, it will be created using `fairland 10 30` or `fairland ${FAIRLAND_OPTS}` if that is defined.

The persistence VOLUME exported is /empserver. This can, and probably should, be mapped to a persistent docker host path or another stopped volume container, ie:

    docker run -d --name empire-data ianblenke/empire echo "Backing store for empire"
    docker run -ti --rm --name empire --volumes-from empire-data -p 3000:3000 -p 6665:6665 -e FAIRLAND_OPTS="10 30" ianblenke/empire

By default, "files" is run, which regenerates the game. Setting `DO_NOT_RUN_FILES` will prevent that from happening if run in the background after initially seeded above:

    docker run -d --name empire --volumes-from empire-data -p 3000:3000 -p 6665:6665 -e DO_NOT_RUN_FILES=1 ianblenke/empire

Now open a web browser to `http://{your docker host}:3000/`

    Country name? POGO
    Your name? peter

You can then execute the fairland created script to create countries and the `visitor`/`visitor` login:

    [0:640] Command : exec /empserver/newcap_script

For help, try `info`.

To change the deity password, use `change re <password>`.

Your game is now up!

Anyone who hits that URL will get a unique empire client session talking to the server.

Enjoy!
