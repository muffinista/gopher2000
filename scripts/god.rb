God.watch do |w|
  w.name = "gopher"
  w.dir = "/home/colin/Projects/gopher2000"
  w.start = "bundle exec /home/colin/Projects/gopher2000/examples/simple.rb"
  w.keepalive
  w.log = '/tmp/gopher.log'

end
