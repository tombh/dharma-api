require './app/init'

require 'nokogiri'
require 'open-uri'

require_relative 'lib/nokogiri_tolerant' # adds helpful selector method that doesn't return so many errors


task :crawl do

	# Itetare over all the folders in 'spiders' and run the spiders.rb file inside those folders
	Dir['spiders/*'].each do |dir|
		site = dir.split('/')[1]
		
		d "Going to scrape '#{site}'"
		
		# Give each spider its own logger
		logger = Logger.new('./logs/' + site + '.log')
		LogBuddy.init({:logger => logger})
		
		# Do it
		require_relative dir + '/spider'
	end	

end