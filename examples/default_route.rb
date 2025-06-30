#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Simple gopher example
#

require 'gopher2000'

set :host, '0.0.0.0'
set :port, 7070

# you can specify a destination for access log, for stats/etc
set :access_log, '/tmp/access.log'

route '/gopher' do
  'Greetings from Gopher 2000!' # You can output any text you want here
end

default_route do
  'I AM HERE'
end
