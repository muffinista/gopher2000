#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#
# Simple gopher example
#

require 'gopher2000'

set :host, '0.0.0.0'
set :port, 7070

# you can specify a destination for access log, for stats/etc
set :access_log, "/tmp/access.log"

route '/gopher' do
  "Greetings from Gopher 2000!" # You can output any text you want here
end

#
# main route
#
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

  # another link
  link 'about', '/about'
  br

  # ask for some input
  input 'Hey, what is your name?', '/hello'
  br

  # ask for some input
  input 'echo test', '/echo_test'
  br

  # mount some files
  menu 'filez', '/files'
end

#
# mounting a directory
#
mount '/files' => '/home/username/files', :filter => '*.jpg'


#
# actions have access to the request object, which has the following attributes:
#
# input: The input string, if provided (for searches, etc)
# selector: The path of the request being made
# ip_address: The remote IP address
#
route '/echo_test' do
  render :echo, request
end

#
# output the results of a search request
#
menu :echo do |req|
  text "#{req.selector} - #{req.ip_address} - #{req.input}"
end

route '/time' do
  "It is currently #{Time.now}"
end

route '/about' do
  "Gopher 2000 -- World Domination via Text Protocols"
end

#
# requests can have variables specified on the URL
#
route '/request/:x/:y' do
  render :request_with_params, params
end

menu :request_with_params do |params|
  text params.inspect
end

route '/hello' do
  render :hello, request.input
end
menu :hello do |name|
  text "Hello, #{name}!"
end

route "/junk" do
  garble
end

helpers do
  def garble; "hhdhd"; end
end
