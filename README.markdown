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

[![Build Status](https://travis-ci.org/muffinista/gopher2000.svg?branch=master)](https://travis-ci.org/muffinista/gopher2000)

Features
--------
* Simple, Sintra-inspired routing DSL.
* Dynamic requests via named parameters on request paths.
* built on Event Machine.
* Easy to mount directories and serve up files.
* built in logging and stats.

Requirements
------------
* Ruby 2 or greater
* Nerves of steel

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
  text_link 'current time', '/time'
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

==> *start server at 0.0.0.0 7070*
```

Or, if you include gopher in your file, you can just run the script itself:

```rb
# scriptname.rb
require 'gopher2000'

# ...
# write some code here
# ...

# Then, run 'ruby scriptname.rb'

==> *start server at 0.0.0.0 7070*
```
There are several command-line options:

* -d -- run in debug mode
* -p [port] -- which port to listen on
* -o [addr] -- what IP/host to listen on
* -e [env] -- what 'environment' to use -- this isn't really used by
  Gopher2000, but you could use it when writing your app to determine
  how you behave in production vs development, etc.

Command line options will override defaults specified in your script
-- so you can try out things on a different port/address if needed.


Docker
------

There's a pretty simple docker script which you can use to run an
app. To run one of the included examples, you could do something like:


```
docker build -t gopher2000 .
docker run -p 7070:7070 --rm -it gopher2000 examples/simple.rb
```

This will run the `simple` example on port 7070. You can view it
locally by running something like:

```
lynx gopher://0.0.0.0:7070
```

The Dockerfile is also published to Docker Hub, so you could run
something like this:

```
docker run -p 7070:7070 --rm -v $PWD:/opt muffinista/gopher2000 /opt/gopher-script.rb
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

Outputting Gopher Menus
-----------------------

There are a collection of commands to output Gopher menus (see
rendering/menu.rb for the code). The commands are:

**line(type, text, selector)** - output a line of type 'type' -- see
  the RFC for the different types of links you can have.

**text** - output a line of text with no action on it.

**br(x)** - output x blank lines.

**error** - output an error message.

**directory** - (aliased as menu) output a link to a 'directory' -- this could be an
  actual directory if you're building some sort of filesystem tree, or
  a sub-menu for other actions in your app.

**link(text, selector)** - output a menu link to to the /selector path.

**search(text, selector)** -- output a link to a search action at
  /selector.

Outputting Text
---------------

If you would like to output text, but have the ability to format it
nicely, you can use a 'text' block like this:

```rb
route '/prettytext' do
  render :prettytext
end

#
# special text output rendering
#
text :prettytext do
  @text = "A really long chunk of text. Lorem ipsum dolor sit amet ... nec massa."

  # nicely wrapped text
  block @text

  # spacing
  br(2)

  # smaller line-width
  block @text, 30
end

```

A call to:

```
echo "/prettytext" | ncat -C localhost 7070
```

Will return your text, but with nice wrapping, etc.

@todo headers, etc.


Making It Pretty
----------------

There are several helpers which you can call within render blocks to
help make your output a little shinier:

**width(x)** will set the width of your output. The default is 80
  characters. You can change this to make your output wider or
  thinner. This setting is used by **block** and also by the methods
  described below.

**header(text, style='=')** will generate a very simple 'header', which is
  basically the text you specify with an underline of the character
  you specify. It will be centered in your output width, and will look
  something like this:

	     Hello There!
	 =====================

**big_header** is the same as header, except it is bigger and better!

	 =====================
	 =   Hello There!    =
	 =====================

**underline** can be used to just output plain old lines, if you're
  into that sort of thing.


Testing
-------

Here's some simple ways to test your server. First, you can always
just install a
[gopher client](http://lmgtfy.com/?q=gopher+clients). Or, if you like
to live on the edge, there's a few commands worth learning. First, you
can use [netcat](http://netcat.sourceforge.net/) to achieve
awesomeness. Here's some examples, assuming you're running the example
script on port 7070:


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

#
# getting a simple text response
#
~/Projects/gopher2000: echo "/about" | nc localhost 7070
Gopher 2000 -- World Domination via Text Protocols
.
```


Or, you can use the equally awesome [ncat](http://nmap.org/ncat/),
which is basically the successor to netcat. In general, I find that
ncat works better, particularly if you're using non-blocking
operations. Here's an example of it in operation:


```
#
# Testing text output
#

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
* Work on putting routing/rendering/etc into same context, and making
  instance variables/methods generally available.
* Documentation
* clean up/improve EventMachine usage
* stats generation

References
----------

* http://www.ietf.org/rfc/rfc1436.txt -- the original RFC for the
  Gopher Protocol
* https://github.com/sinatra/sinatra -- almost everything good in this
  library was taken or influenced by something in Sinatra. RUN don't
  walk to the code and take a look.
