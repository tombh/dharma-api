require "rubygems"
require "bundler/setup"

require 'sinatra/base'
require 'mongo_mapper'
require 'log_buddy'

require_relative 'models'


# read the local configuration
@config = YAML.load_file("./app/settings.yaml")
  
@environment = ENV['RACK_ENV'] || 'development'
@settings = @config[@environment]

logger = Logger.new('.log')


# Database setup
LogBuddy.init(:logger => logger)
MongoMapper.connection = Mongo::Connection.new(@settings['db_host'], @settings['db_port'], :logger => logger)
MongoMapper.database = @settings['db_name']
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