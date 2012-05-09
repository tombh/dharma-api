require "rubygems"
require "bundler/setup"

require 'sinatra/base'
require 'mongo_mapper'
require 'log_buddy'

require_relative 'models'


# read the local configuration
config = YAML.load_file("./app/settings.yaml")
  
environment = ENV['RACK_ENV'] || 'development'
settings = config[environment]

mongo_logger = Logger.new('./logs/mongomapper.log')
app_logger = Logger.new('./logs/app.log')
LogBuddy.init(:logger => app_logger)

d "Using '#{settings['db']['name']}' database"

# Database setup
MongoMapper.connection = Mongo::Connection.new(
  settings['db']['host'], 
  settings['db']['port'], 
  :logger => mongo_logger
)
MongoMapper.database = settings['db']['name']
MongoMapper.connection.connect


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