#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Simple gopher example
#

require 'rubygems'
require 'bundler/setup'
require 'gopher2000'

set :host, '0.0.0.0'
set :port, 7070
set :non_blocking, true

# you can specify a destination for access log, for stats/etc
set :access_log, '/tmp/access.log'

route '/gopher' do
  'Greetings from Gopher 2000!' # You can output any text you want here
end

route '/prettytext' do
  render :prettytext
end

#
# special text output rendering
#
text :prettytext do
  @text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ullamcorper dictum euismod. Sed accumsan sem id quam rutrum eu hendrerit quam adipiscing. Fusce consequat accumsan eros, ac elementum eros molestie et. Vestibulum aliquet varius nulla nec rhoncus. Vivamus felis ipsum, commodo sit amet eleifend eu, lacinia et est. Nullam dolor sapien, luctus eu rhoncus non, ullamcorper vitae nibh. Proin viverra luctus dapibus. Integer aliquam, ante id consectetur vulputate, nibh sapien aliquet nisl, in porttitor massa elit a lectus. Maecenas nec diam nec nulla fringilla feugiat. Nulla facilisi. Proin odio libero, viverra at blandit eget, mattis id dui. Aliquam sed leo leo. Pellentesque eros ante, viverra in accumsan sit amet, pellentesque nec massa.'

  # nicely wrapped text
  block @text

  # spacing
  br(2)

  # smaller line-width
  block @text, 30
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
  text_link 'current time', '/time'
  br

  # another link
  text_link 'about', '/about'
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
  'Gopher 2000 -- World Domination via Text Protocols'
end

#
# requests can have variables specified on the URL
#
route '/request/:x/:y' do
  render :request_with_params
end

# menu :request_with_params do |params|
#  text params.inspect
# end

#
# both the incoming params, and the request object are available when rendering
#
menu :request_with_params do
  text params.inspect
  text request.inspect
end

route '/hello' do
  render :hello, request.input
end
menu :hello do |name|
  text "Hello, #{name}!"
end

route '/junk' do
  garble
end

route '/slow' do
  'i am not fast'
end

helpers do
  def garble = 'hhdhd'
end
