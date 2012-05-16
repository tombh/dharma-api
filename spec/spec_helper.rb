# Careful what you put in here as it shared by the app and all the spiders

ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'rack/test'
require './app/init.rb'
require './app/routes.rb'
require 'json'

RSpec.configure do |config|
  
  config.include Rack::Test::Methods
  
  # Use color in STDOUT
  config.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate  

  config.after(:all) do
    Talk.destroy_all()
    Speaker.destroy_all()
    Key.destroy_all()
  end
end

def app
  Dharma
end