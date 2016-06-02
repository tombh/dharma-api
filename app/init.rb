require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'mongoid'
require 'mail'
require 'tilt/rdiscount'
require 'tilt/erb'

require 'rack/cors'

PROJECT_ROOT = File.expand_path '../../', __FILE__

$LOAD_PATH.unshift PROJECT_ROOT

require 'lib/logging'

require 'app/models'

# read the local configuration
Mongoid.load! File.join PROJECT_ROOT, 'app/mongoid.yml'

environment = ENV['RACK_ENV'] || 'development'

if environment == 'production'

  require 'newrelic_rpm' # Monitoring

  mail_settings = {
    address: 'smtp.sendgrid.net',
    port: '587',
    domain: 'dharma-api.com',
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'],
    authentication: :plain,
    enable_starttls_auto: true
  }

  Mail.defaults do
    delivery_method :smtp, mail_settings
  end
end
