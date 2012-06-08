source "http://rubygems.org"
gem "log_buddy"
gem "nokogiri"
gem "bson_ext"
gem "mongo_mapper"
gem "sinatra"
gem "thin"
gem "mongomapper_plugins", :git => "https://github.com/andrewtimberlake/mongomapper_plugins.git"
gem "mail"
gem "rake"
gem "rdiscount"

gem 'newrelic_rpm'

group :development do
  require 'rbconfig'

  if RbConfig::CONFIG['target_os'] =~ /darwin/i
    gem 'rb-fsevent', '>= 0.3.9'
    gem 'growl', '~> 1.0.3'
  end

  if RbConfig::CONFIG['target_os'] =~ /linux/i
    gem 'rb-inotify', '>= 0.5.1'
    gem 'libnotify', '~> 0.1.3'
  end

  gem "guard"
  gem "guard-bundler"
  gem "guard-rack", :git => "http://github.com/tombh/guard-rack"
  gem "rspec"
end

group :test do
  gem "rack-test"
end
