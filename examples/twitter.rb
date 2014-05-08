#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#
# Output twitter feed via gopher. Has two output methods -- it can
# output as text or as a gopher directory.
#

require 'open-uri'
require 'json'
require 'gopher2000'

set :host, '0.0.0.0'
set :port, 7070

route '/' do
  @username = "mitchc2"
  @url = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{@username}"

  data = open(@url).read

  # to see the output as a gopher directory, try:
  render :twitter_as_menu, @username, data

  # to see text output, try:
  #render :twitter, @username, data
end

text :twitter do |username, data|
  big_header "The Tweets of #{username}"
  JSON.parse(data).each do |t|
    timestamp = Time.parse(t['created_at'])

    block format_tweet(t)
  end
  # this stray break is a bit of a hack to ensure that this block returns
  # the results of rendering, rather than the #each loop above
  br
end

menu :twitter_as_menu do |username, data|
  big_header "The Tweets of #{username}"
  JSON.parse(data).each do |t|
    timestamp = Time.parse(t['created_at'])

    block format_tweet(t)
  end
  # this stray break is a bit of a hack to ensure that this block returns
  # the results of rendering, rather than the #each loop above
  br
end

helpers do
  #
  # simple helper for formatting a tweet
  #
  def format_tweet(t)
    timestamp = Time.parse(t['created_at'])
    "#{timestamp.strftime('%D %r')}: #{t['text']}"
  end
end
