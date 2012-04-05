#!/usr/bin/env ruby

#
# Simple gopher example
#

require 'gopher2000'

set :host, '0.0.0.0'
set :port, 7070

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
  input 'your name plz', '/name'
  br

  # mount some files
  menu 'filez', '/files'
end

mount '/files' => '/home/colin/Projects', :filter => '*.jpg'


#
# actions have access to the request object, and can grab the following data:
#
# input: The input string, if provided (for searches, etc)
# selector: The path of the request being made
# ip_address: The remote IP address
#
route '/name' do
#  render :hello, request.input.strip
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

route '/slow' do
  sleep 2
  render :slow
end
menu :slow do
  text "i'm not too fast"
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


menu :current_time do
  text "present day //// present time"
  text ruler(30)
  br 1
  text current_time
  br 2
  menu 'back', '/'
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
