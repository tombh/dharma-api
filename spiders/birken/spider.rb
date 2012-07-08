# http://birken.ca

# Talks given by Theravadin monastics in the Thai forest tradition, usually 
# tracing their lineage back through Ajahn Chah.

# Yo so bhagavæ arahaµ sammæsambuddho
# To the Blessed One, the Lord, who fully attained perfect enlightenment

class Birken < Spider

  BASE_DOMAIN = 'http://mirror1.birken.ca'
  BASE_URL = BASE_DOMAIN + '/dhamma_talks/indiv/Birken_Dhamma_Talk_Master_List.html'
  LICENSE = 'http://creativecommons.org/licenses/by-nc-nd/2.5/'

  def parse_talk fragment

    permalink = fragment.tolerant_css('li > strong > a', 'href')
    # There has to be a permalink to a talk
    if !permalink.downcase.end_with? 'mp3'
      log.warn "Couldn't get talk's permalink"
      return false
    end

    # Check if it's a link to an external site
    unless permalink.include? 'http://'
      permalink = BASE_DOMAIN + '/' + permalink
    end

    speaker_name = fragment.css('li > strong').first.text

    duration = colon_time_to_seconds fragment.css('li + li > strong').first.text

    speaker = Speaker.first_or_create(:name => speaker_name)

    # Add a profile pic if there isn't one already
    if speaker.picture.nil?
      speaker.update_attributes!(:picture => @pics[speaker_name])
    end

    talk = Talk.first_or_create(:permalink => permalink)
    
    title = fragment.previous.previous.text.gsub('"', '')

    return if title.nil?

    talk_details = {
      :title => title,
      :speaker_id => speaker._id,
      :permalink => permalink,
      :duration => duration,
      :source => 'http://birken.ca',
      :license => LICENSE
    }

    talk.update_attributes!(talk_details)

    d Talk.find_by_permalink(permalink)
    d "\n" 
  end

  def parse_talk_detail detail
    @talk_fragment.tolerant_css('div').scan(/#{detail}: (.*)/).first.first.strip  
  end

  # There's a page that has all the monastics pictures on it.
  # So scrape it and put them into a hash.
  def parse_speaker_pictures
    @pics = {}
    Nokogiri::HTML(open('http://birken.ca/monastics_in_dhamma_talks_info.html')).css('td > p > img').each do |img|
      @pics[img.attribute('alt').text] = img.attribute('src').text
    end
  end

  def initialize(options = {})
    super
    parse_speaker_pictures
  end

  def run
    d "Crawling Birken Master List"
    log.info "Crawl initiated on " + Time.now.inspect
    d "Parsing speaker pictures"
    d "Opening #{BASE_URL}"
    Nokogiri::HTML(open(BASE_URL)).css('ul').each do |ul|
      parse_talk ul
    end
  end

end