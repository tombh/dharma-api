# AUDIODHARMA.Org
# A very large collection of dharma talks, given at the Insight Meditation Center in California.
# We make use of the fact that Audidharma paginates all its talks on a consistent URL.
# Audidharma also has a rich archive of teachers; with bios, pics and website links, these
# pages are kept on seperate pages which we can easily parse.

# May all beings be from suffering

class Audiodharma < Spider

  BASE_DOMAIN = 'http://audiodharma.org'
  BASE_URL = BASE_DOMAIN + '/talks/?page='

  # Parse a speaker's page for relevant info
  def scrape_speaker(doc, speaker_name)
    table = doc.at_css('.teacher_bio_table')

    if not table
      log.warn "DOM elements for speaker not found :: #{speaker_name}"
      return false
    end

    {
      :name => speaker_name, # Use the name from the original talk page in case there's nothing else
      :bio => clean_long_text(table.tolerant_css('.teacher_bio')),
      :website => table.parent.tolerant_css('div + div a' , 'href'),
      :picture => table.tolerant_css('.teacher_photo img', 'src')
    }
  end

  # There's an edge case where a talk will contain multiple files or parts
  def check_multitalk_edge_case
    @multiple_talk = false
    # This identifies the fragment containing the links to the actual mp3s
    fifth_td = @talk_fragment.css('td')[4]
    if fifth_td.text == "View Series"
      d "This 'talk' is a reference to a series of talks"
      @multiple_talk = fifth_td.attr('href')
    end
    @multiple_talk
  end

  # Find the speaker for the current talk.
  # The full speaker details are kept on a seperate page which we need to fetch.
  # But we keep a track of which speakers we've already fetched on this crawl so we only
  # scrape them once.
  def parse_speaker
    # No need to continue if we can't even find a speaker name
    speaker_name = @talk_fragment.tolerant_css('.talk_teacher')
    if speaker_name.empty?
      log.warn "Couldn't find the speaker in :: " + @talk_fragment
      return false
    end

    # Only parse this speaker if we haven't done so on this crawl already
    if @parsed_speakers.include? speaker_name
      d "Speaker already parsed (#{speaker_name})"
      @speaker = Speaker.find_by_name(speaker_name)
      return @speaker
    end

    d "Unparsed speaker :: " + speaker_name
    href = @talk_fragment.tolerant_css('.talk_teacher a', 'href')
    doc = Nokogiri::HTML(open_speaker_doc(BASE_DOMAIN + href))
    if not speaker_scraped = scrape_speaker(doc, speaker_name)
      log.warn "Couldn't parse the speaker target page :: " + href
      return false
    end

    # See if there's a record of the speaker in the db and create one if there isn't
    @speaker = Speaker.find_by_name(speaker_name) || Speaker.new
    @speaker.update_attributes!(speaker_scraped)
    @parsed_speakers << speaker_name # Make a note of this so we don't do it again on this crawl

    @speaker
  end

  def parse_talk
    # There has to be a permalink to a talk
    if not permalink = @talk_fragment.tolerant_css('.talk_links a', 'href')
      log.warn "Couldn't get talk's permalink"
      return false
    end

    # Some talks are external links and some are relative internal ones
    unless permalink.include? 'http://'
      permalink = BASE_DOMAIN + permalink
    end

    # See if this talk exists and update or create
    talk = Talk.find_by_permalink(permalink) || Talk.new
    
    @talk_scraped = {
      :title => @talk_fragment.tolerant_css('.talk_title'),
      :speaker_id => @speaker._id,
      :permalink => permalink,
      :duration => colon_time_to_seconds(@talk_fragment.tolerant_css('.talk_length')),
      :date => @talk_fragment.tolerant_css('.talk_date'),
      :description => clean_long_text(@talk_fragment.tolerant_css('.the_talk_description')),
      :venue => "Insight Meditation Centre, Redwood, California",
      :event => nil # TODO Detect when a talk is part of a series
    }
    
    talk.update_attributes!(@talk_scraped)
    d "Talk :: " + talk.title
    
    talk
  end

  def talks(doc)
    talks = Nokogiri::HTML(doc).css('.talklist tr')
    talks.shift # Remove first element, cos it's just the table header
    talks
  end

  # Take a page and extract data from it
  def scrape_page(doc)
    # A page typically contains 50 or so talks
    talks(doc).each do |talk_fragment|

      d "---------------------------------------"

      @talk_fragment = talk_fragment

      # First check if this is just a link to a series of talks
      if series_url = check_multitalk_edge_case()
        scrape_page(open(doc))
        next
      end

      parse_talk() if parse_speaker()
    end
  end

  # Loop over all of audiodharma's pages
  def run
    d "Crawling AUDIODHARMA, starting on page #{@page}"
    log.info "Crawl initiated on " + Time.now.inspect    
    @page -= 1
    while
      @page += 1
      full_link = BASE_URL + @page.to_s
      d "\n#######################################"
      d "Link to current page :: " + full_link
      doc = open(full_link).read
      doc =~ /No matching talks are available/ and break # Fin
      scrape_page(doc)
    end
    d "Fin"
  end

end