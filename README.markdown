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

Developing Gopher Sites
-----------------------

Gopher2000 makes developing sites easy! Any time you change your
script, Gopher2000 will reload it. This way, you can make tweaks and
your site will be refreshed immediately. NOTE -- this is an
experimental feature, and might need some work.

Serving Files and Directories
-----------------------------

If you just want to serve up some files, there's a command for that:

```rb
mount '/files' => '/home/username/files', :filter => '*.jpg'
```

This will display a list of all the JPGs in the files directory.

Testing
-------

Here's some simple ways to test your server. First, you can always
just install a
[gopher client](http://lmgtfy.com/?q=gopher+clients). Or, if you like
to live on the edge, there's a few commands worth learning. First, you
can use [netcat](http://netcat.sourceforge.net/) to achieve
awesomeness. Here's some examples, assuming you're running the example script on
port 7070:


```

#
# getting a menu listing
#

~/Projects/gopher2000: echo "/" | nc localhost 7070
isimple gopher example	null	(FALSE)	0
i	null	(FALSE)	0
i	null	(FALSE)	0
0current time	/time	0.0.0.0	7070
i	null	(FALSE)	0
0about	/about	0.0.0.0	7070
i	null	(FALSE)	0
7Hey, what is your name?	/hello	0.0.0.0	7070
i	null	(FALSE)	0
7echo test	/echo_test	0.0.0.0	7070
i	null	(FALSE)	0
1filez	/files	0.0.0.0	7070
```

#
# getting a simple text response
#
~/Projects/gopher2000: echo "/about" | nc localhost 7070
Gopher 2000 -- World Domination via Text Protocols
.
```


Or, you can use the equally awesome [ncat](http://nmap.org/ncat/),
which is basically the successor to netcat:

```
~/Projects/gopher2000: echo "/about" | ncat -C localhost 7070
Gopher 2000 -- World Domination via Text Protocols
.

#
# testing a route with some input
#

~/Projects/gopher2000: echo "/hello\tcolin" | ncat -C localhost 7070
iHello, colin!	null	(FALSE)	0

.

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

Non-Blocking Requests
---------------------

When not running in debug mode, Gopher2000 will handle requests
without blocking -- this way, if you have an app that handles slow
requests, your users aren't held up waiting for other requests to
finish. However, this is somewhat experimental, so you can turn it off
by setting :non_blocking to be false in your script:

```rb
set :non_blocking, false
```

Also, non-blocking is always off in debug mode.

You probably need to be wary of this feature if you're actually
running a Gopher server that needs to be non-blocking. Read up on
EventMachine's defer feature if you need to learn more.


TODO
----
* More examples
* Documentation
* clean up/improve EventMachine usage
* stats generation
