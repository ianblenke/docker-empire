## ianblenke/empire

This is a docker image for [empire](http://www.wolfpackempire.com/) built from the sourceforge [empserver](https://empserver.sf.net) source

(3) Creating a game

    * Create a configuration for your game.  make install installs one
      in $prefix/etc/empire/econfig ($prefix is /usr/local unless you
      chose something else with configure).  You can use pconfig to
      create another one.

    * Edit your configuration file.  See doc/econfig for more
      information.

      Unless you put your configuration file in the default location
      (where make install installs it), you have to use -e with all
      programs to make them use your configuration.

    * Run files to set up your data directory.

    * Run fairland to create a world.  For a sample world, try
      `fairland 10 30'.  This creates file ./newcap_script, which will
      be used below.  You can edit it to change country names and
      passwords.

      Check out fairland's manual page for more information.

    * Start the server.  For development, you want to run it with -d
      in a debugger, see doc/debugging.  Do not use -d for a real
      game!

    * Log in as deity POGO with password peter.  This guide assumes
      you use the included client `empire', but other clients should
      work as well.

      For help, try `info'.

      To change the deity password, use `change re <password>'.

    * Create countries with `exec newcap_script'.

    Your game is now up!

