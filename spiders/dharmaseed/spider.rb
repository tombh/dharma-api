# DHARMASEED.ORG
# OProably the biggest resoure of dharma talks on the net. 
# We make use of the fact that Dharmaseed paginates all its talks on a consistent URL.
# Dharmaseed also has a rich archive of teachers, with bios, pics and website links, these
# pages are kept on sepearte pages which we can easily parse

# Nokgiri's at_css method is the same as css() (and jQuery's $), except it pops off the first element
# Also note tolerant_css that is more forgiving and also _and_ returns the matched element's contents
# by default.

# May all beings be from suffering


url = 'http://www.dharmaseed.org/talks/?page='


# Parse a speaker's page for relevant info
def parse_speaker(url)
  doc = Nokogiri::HTML(open('http://dharmaseed.org' + url))
  table = doc.at_css('.talklist table')

  if not table
    Nokogiri.logger.error "DOM elements for speaker not found"
    return nil
  end

  {
    :name => table.tolerant_css('.talkteacher b'),
    :bio => table.tolerant_css('tr + tr td > i'),
    :website => table.tolerant_css('tr td table tr td.talkbutton a', 'href'),
    :picture => table.tolerant_css('tr td table tr td a.talkteacher img', 'src')
  }
end


# Loop over all of dharmaseed's pages
parsed_speakers = []
page = 0
begin
  page += 1
  full_link = url + page.to_s
  if not doc = open(full_link)
    finished = true
  end
  
  d "Link to current page :: " + full_link + "\n"

  # The .talklist tables contain the ore
  talk_scraped, speaker_name = nil # defining outside of loop allows vars to persist across iterations
  doc = Nokogiri::HTML(doc)
  doc.css('.talklist table').each do |table|
    
    begin
      # Relevant table rows in the DOM
      one = table.at_css('tr td')
      two = table.at_css('tr + tr td')
      three = table.at_css('tr + tr + tr td') 
    rescue Exception => e
      # Might not be a show stopper, but something's up
      Nokogiri.logger.warning "Some or all of the DOM elements needed to parse the talk are missing (#{e.message})"
    end
    

    # SPEAKER
    # Speaker name is required
    
    # Handle edge case where multiple talks are included in one
    # eg; http://www.dharmaseed.org/teacher/175/talk/15391/
    if table.tolerant_css('.talkbutton a + a') == 'Show Tracks' # This is the parent 'talk'
      parent_of_multiple_talks = true
    end

    id = table.parent.attr('id')
    if id && id.starts_with?('tracklist')
      multiple_talks = true
      d "This talk is part of the 'multiple_talks' edge case"
      # just keep speaker_name from the previous loop :)
    else
      multiple_talks = false
      if not speaker_name = two.tolerant_css('i a')
        Speaker.logger.error "Couldn't find the speaker"
        next
      end
    end
    
    # Only parse this speaker if we haven't done so on this crawl already
    if not parsed_speakers.include? speaker_name

      if not speaker_scraped = parse_speaker(two.tolerant_css('i a', 'href'))
        Speaker.logger.error "Couldn't parse the speaker target page"
        next
      end

      # See if there's a record of the speaker and create one if there isn't
      speaker = Speaker.find_by_name(speaker_name) || Speaker.new
      speaker.update_attributes!(speaker_scraped)     
      parsed_speakers << speaker_name

      d "Speaker :: " + speaker.name
    
    else
    
      speaker = Speaker.find_by_name(speaker_name)
    
    end

    # TALK
    
    # There has to be a permalink to a talk     
    if not permalink = table.tolerant_css('.talkbutton a', 'href')
      Talk.logger.error "Couldn't get talk's permalink"
      next
    end

    # See if this talk exists and update or create
    talk = Talk.find_by_permalink(permalink) || Talk.new

    if multiple_talks
      # use talk object from prevous loop as base and merge in new values
      talk_scraped = talk_scraped.merge({
        :title => one.tolerant_css('a'),
        :permalink => permalink,
        :duration => one.tolerant_css('i')        
      })
    else
      talk_scraped = {
        :title => one.tolerant_css('a'),
        :speaker_id => speaker._id,
        :permalink => permalink,
        :duration => one.tolerant_css('i'),
        :date => one ? one.text.split[0] : nil,
        :description => three.text, # assigns venue & event when no description
        :venue => three.tolerant_css('a'),
        :event => three.tolerant_css('a + a')
      }
    end
    
    # The parent of a set of multiple talks contains all the information for the child talks,
    # but it does not itself have a link to an mp3. Therefore we do everything but persist this
    # talk as talk_scraped will be merged with successive child talks
    if not parent_of_multiple_talks
      talk.update_attributes!(talk_scraped)
      d "Talk :: " + talk.title
    end

  end   
  
end until finished