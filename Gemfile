source "http://rubygems.org"

# Specify your gem's dependencies in gopher.gemspec
gemspec

gem "rake"
gem "logging"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'simplecov', :require => false, :group => :test

  gem "shoulda", ">= 0"
  gem "rspec"

  gem "bundler", "~> 1.0.0"
  gem "watchr"
end


gem "weather-underground"