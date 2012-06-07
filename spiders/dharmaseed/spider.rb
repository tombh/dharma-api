# DHARMASEED.ORG
# Probably the biggest resource of dharma talks on the net.
# We make use of the fact that Dharmaseed paginates all its talks on a consistent URL.
# Dharmaseed also has a rich archive of teachers; with bios, pics and website links, these
# pages are kept on seperate pages which we can easily parse

# Nokgiri's at_css method is the same as css() (and jQuery's $), except it pops off the first element.
# Also note tolerant_css() that is more forgiving _and_ returns the matched element's contents
# by default.

# May all beings be from suffering

class Dharmaseed < Spider

  BASE_DOMAIN = 'http://dharmaseed.org'
  BASE_URL = BASE_DOMAIN + '/talks/?page='
  LICENSE = 'http://creativecommons.org/licenses/by-nc-nd/3.0/'

  # Parse a speaker's page for relevant info
  def scrape_speaker(doc, speaker_name)
    table = doc.at_css('.talklist table')

    if not table
      log.warn "DOM elements for speaker not found"
      return false
    end

    {
      :name => speaker_name, # Use the name from the original talk page in case there's nothing else
      :bio => clean_long_text(table.tolerant_css('tr + tr td > i')),
      :website => table.tolerant_css('tr td table tr td.talkbutton a', 'href'),
      :picture => table.tolerant_css('tr td table tr td a.talkteacher img', 'src')
    }
  end

  # There's an edge case where a talk will contain multiple files or parts
  def check_multitalk_edge_case
    @multiple_talk = false
    @parent_of_multiple_talks = false

    # Firstly check whether this is the parent 'talk'. It won't actually contain the
    # mp3 but will contain a lots of the other details that will be common to all the
    # tracks that make up this talk.
    # The best signature is to look out for is a button that shows/hides the tracks
    if @talk_fragment.tolerant_css('.talkbutton a + a') == 'Show Tracks'
      d "This 'talk' is a parent of multiple talks"
      @parent_of_multiple_talks = true
    end

    # This identifies the fragment containing the links to the actual mp3s
    id = @talk_fragment.parent.attr('id')
    if id && id.starts_with?('tracklist')
      d "This talk is part of the 'multitalks' edge case"
      @multiple_talk = true
    end
  end

  # Find the speaker for the current talk.
  # The full speaker details are kept on a seperate page which we need to fetch.
  # But we keep a track of which speakers we've already fetched on this crawl so we only
  # scrape them once.
  def parse_speaker

    @multiple_talk and return true

    # No need to continue if we can't even find a speaker name
    if not speaker_name = @two.tolerant_css('i a')
      log.warn "Couldn't find the speaker in :: " + @two
      return false
    end

    # Only parse this speaker if we haven't done so on this crawl already
    if @parsed_speakers.include? speaker_name
      d "Speaker already parsed (#{speaker_name})"
      @speaker = Speaker.find_by_name(speaker_name)
      return @speaker
    end

    d "Unparsed speaker :: " + speaker_name
    href = @two.tolerant_css('i a', 'href')
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

  # Given the 3 <tr> rows (@one, @two, @three) of a talk fragment enter it in the db
  def parse_talk
    # There has to be a permalink to a talk
    if not permalink = @talk_fragment.tolerant_css('.talkbutton a', 'href')
      log.warn "Couldn't get talk's permalink"
      return false
    end

    # Some talks are full links to Vimeo videos.
    # But most of them are relative links to dharmaseed.org
    unless permalink.include? 'http://'
      permalink = BASE_DOMAIN + permalink
    end

    talk = Talk.find_by_permalink(permalink) 
    
    # If the talk exists and we're not doing a recrawl then we end it here.
    if talk and !@recrawl
      @finished = true
      d "Found existing talk, ending crawl."
      return false
    end

    talk = Talk.new if !talk

    if @multiple_talk
      # use talk object from prevous loop as base and merge in new values
      @talk_scraped = @talk_scraped.merge({
        :title => @one.tolerant_css('a'),
        :permalink => permalink,
        :duration => @one.tolerant_css('i')
      })
    else
      @talk_scraped = {
        :title => @one.tolerant_css('a'),
        :speaker_id => @speaker._id,
        :permalink => permalink,
        :duration => colon_time_to_seconds(@one.tolerant_css('i')),
        :date => @one ? @one.text.split[0] : nil,
        :description => clean_long_text(@three.text), # assigns venue & event when there's no description
        :venue => @three.tolerant_css('a'),
        :event => @three.tolerant_css('a + a'),
        :source => BASE_DOMAIN,
        :license => LICENSE
      }
    end

    # The parent of a set of multiple talks contains all the information for the child talks,
    # but it does not itself have a link to an mp3. Therefore we do everything but persist this
    # talk as talk_scraped will be merged with successive child talks.
    if not @parent_of_multiple_talks
      talk.update_attributes!(@talk_scraped)
      d "Talk :: " + talk.title
    end

    talk
  end

  def isolate_table_rows()
    @one = @talk_fragment.at_css('tr td')
    @two = @talk_fragment.at_css('tr + tr td')
    @three = @talk_fragment.at_css('tr + tr + tr td')
  end

  def talklist_tables(doc)
    Nokogiri::HTML(doc).css('.talklist table')
  end

  # Take a dharmaseed page and extract data from it
  def scrape_page(doc)
    # A page typically contains 10 or so talks
    talklist_tables(doc).each do |talk_fragment|

      d "---------------------------------------"

      @talk_fragment = talk_fragment
      isolate_table_rows()

      # First check for edge case where multiple talks are included in one
      # eg; http://www.dharmaseed.org/teacher/175/talk/15391/
      check_multitalk_edge_case()

      parse_talk() if parse_speaker()
      break if @finished
    end
  end

  # Loop over all of dharmaseed's pages
  def run
    d "Crawling DHARMASEED, starting on page #{@page}"
    log.info "Crawl initiated on " + Time.now.inspect    
    @page -= 1
    while
      @page += 1
      full_link = BASE_URL + @page.to_s
      d "\n#######################################"
      d "Link to current page :: " + full_link
      doc = open(full_link).read
      doc =~ /No matching talks are available/ and break
      scrape_page(doc)
      break if @finished
    end
  end

end