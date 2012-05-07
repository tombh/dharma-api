require './app/init'

require 'nokogiri'
require 'open-uri'

task :crawl do
	puts "Crawling ... \n"

	url = 'http://www.dharmaseed.org/talks/?page='

	page = 0
	begin
		page += 1
		if not doc = open(url + page.to_s)
			finished = true
		end
		
		doc = Nokogiri::HTML(doc)
		doc.css('.talklist table').each do |table|
			first = table.css('tr')[0].css('td')[0] 
			date = first.inner_text().split[0].strip
			title = first.css('a')[0].content.strip
			duration = first.css('i')[0].content.strip

			puts date + "\n" + title + "\n" + duration
		end

		
		#@speaker = Speaker.new
		#@speaker.name = "tombh"
		#@speaker.bio ="he came, he saw, etc"
		#if @speaker.save
		#	puts "saved"
		#end
	end until finished

	
end