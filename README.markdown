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
* built in logging and stats.
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

Running a script
----------------

You can use the supplied wrapper script

```
gopher2000 -d examples/simple.rb
```

Or, if you include gopher in your file, you can just run the script itself:

```rb
require 'gopher2000'
```
There are several command-line options:

* -d -- run in debug mode
* -p [port] -- which port to listen on
* -o [addr] -- what IP/host to listen on
* -e [env] -- what 'environment' to use -- this isn't really used by
  Gopher2000, but you could use it when writing your app to determine
  how you behave in production vs development, etc.


```
# ruby script.rb

==> *start server at 0.0.0.0 7070*
```

Logging
-------

Logging is pretty basic at the moment. Right now debug messages are
dumped to stderr. There's also an apache-esque access log, which can
be written to a file specified like this:

```rb
set :access_log, "/tmp/access.log"
```

The log will rollover daily, so your million hits per day won't
accumulate into an unmanageable file.

The format is a pretty basic tab-delimited file:

	timestamp 		   	ip_address	request_url		result_code	response_size
	2012-04-05 19:14:01	127.0.0.1	/lookup			success		46


TODO
----
* More examples
* clean up/improve EventMachine usage
* stats generation
