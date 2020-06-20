FROM ruby:2.6.5
MAINTAINER Colin Mitchell <colin@muffinlabs.com>

ENV GOPHER_ADDRESS localhost
ENV GOPHER_PORT 70

EXPOSE $GOPHER_PORT

RUN mkdir /app 
WORKDIR /app

COPY . /app

RUN gem install bundler && bundle install

CMD ["bundle", "exec", "gopher2000"]

