require './app/init'

require 'nokogiri'
require 'open-uri'

require_relative 'lib/nokogiri_tolerant'


task :crawl do

	# TODO setup auto parsing from spiders folder

	# Parse a speaker's page for relevant info
	def parse_speaker(url)
		doc = Nokogiri::HTML(open('http://dharmaseed.org' + url))
		table = doc.at_css('.talklist table')

		if not table
			puts "ERROR: DOM elements for speaker not found"
			return nil
		end

		{
			:name => table.tolerant_css('.talkteacher b'),
			:bio => table.tolerant_css('tr + tr td > i'),
			:website => table.tolerant_css('tr td table tr td.talkbutton a', 'href'),
			:picture => table.tolerant_css('tr td table tr td a.talkteacher img', 'src')
		}
	end

	puts "Crawling ... \n"

	url = 'http://www.dharmaseed.org/talks/?page='

	# Loop over all of dharmaseed's pages
	page = 0
	begin
		page += 1
		full_link = url + page.to_s
		if not doc = open(full_link)
			finished = true
		end
		
		print "Link to current page " + full_link + "\n"

		# The .talklist tables contain the ore
		doc = Nokogiri::HTML(doc)
		doc.css('.talklist table').each do |table|
			
			begin
				# Relevant table rows in the DOM
				one = table.at_css('tr td')
				two = table.at_css('tr + tr td')
				three = table.at_css('tr + tr + tr td')
			rescue Exception => e
				puts "Some or all of the DOM elements for a talk are missing (#{e.message})"
			end

			# SPEAKER
			# Speaker name is required
			if not speaker_link = two.at_css('i a')
				puts "ERROR: Couldn't find the speaker"
				next
			end

			href = speaker_link.attr('href')
			speaker_name = speaker_link.text

			# TODO only parse speaker once in rake run		

			# See if there's a record of the speaker and create one if there isn't
			speaker = Speaker.find_by_name(speaker_name) || Speaker.new
			speaker.update_attributes!(parse_speaker(href))
			puts "UPDATED SPEAKER > " + speaker.name

			# TALK
			# There has to be a permalink to a talk			
			if not permalink = table.tolerant_css('.talkbutton a', 'href')
				puts "ERROR: Couldn't get talk's permalink"
				next
			end
			
			talk_scraped = {
				:title => one.tolerant_css('a'),
				:speaker_id => speaker._id,
				:permalink => permalink,
				:duration => one.tolerant_css('i'),
				:date => one ? one.text.split[0] : nil,
				:description => two ? two.text : nil,
				:venue => three.tolerant_css('a'),
				:event => three.tolerant_css('a + a')		
			}

			# See if this talk exists and update or create
			talk = Talk.find_by_permalink(permalink) || Talk.new
			talk.update_attributes!(talk_scraped)
			puts "UPDATED TALK > " + talk.title + " :: " + talk.duration + " :: " + talk.speaker.name
		end		
		
	end until finished

end