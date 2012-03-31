It's...

	 _____             _                 _____  _____  _____  _____
    |  __ \           | |               / __  \|  _  ||  _  ||  _  |
    | |  \/ ___  _ __ | |__   ___ _ __  `' / /'| |/' || |/' || |/' |
    | | __ / _ \| '_ \| '_ \ / _ \ '__|   / /  |  /| ||  /| ||  /| |
    | |_\ \ (_) | |_) | | | |  __/ |    ./ /___\ |_/ /\ |_/ /\ |_/ /
     \____/\___/| .__/|_| |_|\___|_|    \_____/ \___/  \___/  \___/
                | |
                |_|


Gopher2000 - A Gopher server for the next millenium
===================================================

Gopher2000 is a ruby-based Gopher server. It is built for speedy, enjoyable development of
all sorts of gopher sites.

Features
--------
* Simple, Sintra-inspired routing DSL.
* Dynamic requests via named parameters on request paths.
* built on Event Machine.
* Easy to mount directories and serve up files.
* built in Logging/Stats.
* Runs on Ruby 1.9.2 with all the modern conveniences.

Examples
--------

Writing a functional Gopher app is as simple as:

```rb
route '/simple' do
	"hi" # You can output any text you want here
end
```


Or, if you want to provide more interactivity, you can do something like:

```rb
route '/' do
  render :index
end

#
# main index for the server
#
menu :index do
  # output a text entry in the menu
  text 'simple gopher example'

  # use br(x) to add x space between lines
  br(2)

  # link somewhere
  link 'current time', '/time'
  br
end

route '/time' do
  "It is currently #{Time.now}"
end
```

You can see more working examples in the examples/ folder


Getting Started
---------------

Logging
-------

TODO
----
* Get logging working
* Initscripts
* stats
