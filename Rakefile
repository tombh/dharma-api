require './app/init'
require 'spiders/init'

require 'optparse'


task :crawl do

  options = {}
  OptionParser.new do |opts|
    opts.banner = "Crawl usage: crawl [options]"

    opts.on("-s", "--spider [SPIDER]", "Choose which spider to run") do |s|
      options[:spider] = s
    end

    opts.on("-p", "--start_page NUM", "Specify the page to start on (For those spiders that iterate over paginators)") do |p|
      options[:start_page] = p
    end

    opts.on("-r", "--recrawl", "Re-crawl and update everything, rather than just adding new stuff") do |r|
      options[:recrawl] = r
    end
  end.parse!

  if not options[:spider]

    d "Crawling with all spiders."

    # Itetare over all the folders in 'spiders' and run the spiders.rb file inside those folders
    Dir['spiders/*'].each do |dir|        
      !File::directory? dir and next
      spider = dir.split('/')[1]    
      # Do it
      require dir + '/spider'
      # Capitalize first letter of spider, eg; dharmaseed to Dharmaseed
      # Then turn that string into a true language constant representing a class name
      # Then call the .run() method on the object
      spider.capitalize::constantize.new.run
    end

  else
    spider = options[:spider]
    page = options[:start_page] ? options[:start_page] : 1
    require 'spiders/' + spider + '/spider'      
    spider.capitalize::constantize.new(start_page = page).run
  end

end