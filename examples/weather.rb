#!/usr/bin/env ruby
# frozen_string_literal: true

#
# gopher app for retrieving the weather
#

require 'weather-underground'
require 'gopher'

set :host, '0.0.0.0'
set :port, 7070

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
  text "Let's check the weather!"

  # use br(x) to add x space between lines
  br(2)

  # ask for some input
  input 'Please enter your zipcode', '/lookup'
end

#
# actions have access to the request object, and can grab the following data:
#
# input: The input string, if provided (for searches, etc)
# selector: The path of the request being made
# ip_address: The remote IP address
#
#  location = request.input.strip

route '/lookup' do
  location = request.input.strip
  w = WeatherUnderground::Base.new
  f = w.TextForecast(location)

  render :forecast, f, location
end

#
# output the results of a search request
#
menu :forecast do |f, location|
  br
  text "** FORECAST FOR #{location} **"
  br
  f.days.each do |day|
    block "#{day.title}: #{day.text}", 70
    br
  end
  br
  text '** Powered by Gopher 2000 **'
end
