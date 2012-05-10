ENV['RACK_ENV'] = 'test'
require './app/init.rb'

# Pretty colours
# Delete all test data
RSpec.configure do |config|
  # Use color in STDOUT
  config.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate

  config.after(:all) do
    Talk.destroy_all()
    Speaker.destroy_all()
  end
end