source "http://rubygems.org"
gem "log_buddy"
gem "nokogiri"
gem "bson_ext"
gem "mongo_mapper"
gem "sinatra"
gem "thin"
gem "mongomapper_plugins", :git => "https://github.com/andrewtimberlake/mongomapper_plugins.git"
gem "mail"

group :development do
  gem "guard"
  gem "guard-bundler"
  # I've forked my own version that sends a different kill signal to rack.
  # This gives me much faster restart times.
  # See https://github.com/dblock/guard-rack/issues/2
  gem "guard-rack", :git => "https://github.com/tombh/guard-rack"
  gem "rspec"
end

group :test do
  gem "rake"
  gem "rack-test"
end