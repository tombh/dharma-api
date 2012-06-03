# forestsanghapublications.org


class Forestsangha < Spider

  BASE_DOMAIN = 'http://forestsanghapublications.org'
  BASE_URL = BASE_DOMAIN + '/viewTalk.php?id='
  LICENSE = 'http://creativecommons.org/licenses/by-nc-nd/3.0/'

  def parse_talk doc

    @talk_fragment = doc.at_css('.product-display')

    # There has to be a permalink to a talk
    if not permalink = talk_fragment.tolerant_css('div > a', 'href')
      log.warn "Couldn't get talk's permalink"
      return false
    end

    # Check if it's a link to an external site
    unless permalink.include? 'http://'
      permalink = BASE_DOMAIN + '/' + permalink
    end

    speaker_name = parse_talk_detail('Speaker')

    speaker = Speaker.first_or_create(:name => speaker_name)

    # If the talk exists and we're not doing a recrawl then we end it here.
    talk = Talk.find_by_permalink(permalink) || Talk.new
    
    talk_details = {
      :title => parse_talk_detail('Title'),
      :speaker_id => speaker._id,
      :permalink => permalink,
      :description => parse_talk_detail('Album'),
      :source => BASE_DOMAIN,
      :license => LICENSE
    }

    d talk_details
    d "\n" 

    talk.update_attributes!(talk_details)

  end

  def parse_talk_detail detail
    @talk_fragment.tolerant_css('div').scan(/#{detail}: (.*)/).first.first.strip  
  end

  def run
    d "Crawling Forest Sangha Publications starting on page #{@page}"
    log.info "Crawl initiated on " + Time.now.inspect
    # Don't always start from the beginning
    if @recrawl
      @page = 0
    else
      # We can use the total number of talks in the DB as a base for where to start
      @page = Talk.where(:source => BASE_DOMAIN).count
    end
    empty_talk_count = 0
    while
      @page += 1
      href = BASE_URL + @page.to_s
      d "Opening #{href}"
      doc_string = open(href).read
      if doc_string.index('Failed to generate talk object for ID') 
        empty_talk_count += 1
        # Crude way of managing intermittent broken talks
        # The actual end of the all the talks should occur way out into the thousands 
        break if @page > 1200 and empty_talk_count > 10
        next
      end
      parse_talk Nokogiri::HTML(doc_string)
    end
  end

end