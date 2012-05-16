require "rubygems"
require "bundler/setup"

require 'sinatra/base'
require 'mongo_mapper'
require 'mongo_mapper/plugins/auto_increment_id'
require 'mail'

PROJECT_ROOT = File.expand_path("../../", __FILE__)

$:.unshift PROJECT_ROOT # Add PROJECT_ROOT to Ruby's include path

require 'lib/logging'

require 'app/models'

# read the local configuration
config = YAML.load_file("./app/settings.yaml")
  
environment = ENV['RACK_ENV'] || 'development'
settings = config[environment]

if environment != 'production'
  puts "Using '#{settings['db']['name']}' database."
end

# Database setup
MongoMapper.database = settings['db']['name']
MongoMapper.connection = Mongo::Connection.new(
  settings['db']['host'], 
  settings['db']['port'], 
  :logger => MONGO_LOGGER
)
if settings['db']['password']
  MongoMapper.connection.authenticate(
    settings['db']['user'], 
    ENV['MONGOLAB_PASSWORD']
  )
end
MongoMapper.connection.connect

puts settings

# Strip strings before they're placed in the db
module MongoMapper
  module Plugins
    module Stripper
      extend ActiveSupport::Concern

      included do
        before_validation :strip_attributes
      end
      
      def strip_attributes
        attributes.each do |key, value|
          if value.is_a?(String)
            value = value.strip
            value = nil if value.blank?
            self[key] = value
          end
        end
      end
    end
  end
end
MongoMapper::Document.plugin(MongoMapper::Plugins::Stripper)


# Mail.defaults do
#   delivery_method :sendmail, 
#   :address    => "pop.gmail.com",
#   :port       => 995,
#   :user_name  => '<username>',
#   :password   => '<password>'
# end