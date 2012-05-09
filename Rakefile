require './app/init'
require './spiders/init'

task :crawl do

  # Itetare over all the folders in 'spiders' and run the spiders.rb file inside those folders
  Dir['spiders/*'].each do |dir|
    spider = dir.split('/')[1]
    
    d "Going to scrape '#{spider}'"
    
    # Give each spider its own logger
    logger = Logger.new('./logs/' + spider + '.log')
    LogBuddy.init({:logger => logger})
    
    # Do it
    require_relative dir + '/spider'
    # Capitalize first letter of spider, eg; dharmaseed to Dharmaseed
    # Then turn that string into a true language constant reprsenting a class name
    # Then call the #run() method on that class name
    spider.capitalize::constantize.new.run
  end 

end