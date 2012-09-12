# http://birken.ca

# Talks given by Theravadin monastics in the Thai forest tradition, usually 
# tracing their lineage back through Ajahn Chah.

# Yo so bhagavæ arahaµ sammæsambuddho
# To the Blessed One, the Lord, who fully attained perfect enlightenment

class Sfzc < Spider

  BASE_DOMAIN = 'http://www.sfzc.org'
  BASE_URL = BASE_DOMAIN + '/zc/display.asp?catid=1,10&pageid=440'
  LICENSE = 'http://creativecommons.org/licenses/by-nc-nd/3.0/deed.en_US'

  def parse_talk fragment

    fragment.css('td')[0]

    permalink = fragment.css('td')[2].css('a')[1].attr('href')
    # There has to be a permalink to a talk
    if permalink.nil?
      log.warn "Couldn't get talk's permalink"
      return false
    end

    title = fragment.css('td')[1].tolerant_css('a')

    speaker_name = title.split(' - ').first

    speaker = Speaker.first_or_create(:name => speaker_name)
    
    title = title.split(' - ')[1]

    talk = Talk.first_or_create(:permalink => permalink)

    return if title =~ /^\s*$/

    talk_details = {
      :title => title,
      :speaker_id => speaker._id,
      :permalink => permalink,
      :date => fragment.css('td')[0].text,
      :source => BASE_DOMAIN,
      :license => LICENSE
    }

    talk.update_attributes!(talk_details)

    d Talk.find_by_permalink(permalink)
    d "\n" 
  end

  def parse_page page
    Nokogiri::HTML(page).css('table.datasm1 tr').each do |row|
      parse_talk row
    end
  end

  def run
    d "Crawling SFZC"
    log.info "Crawl initiated on " + Time.now.inspect
    d "Opening #{BASE_URL}"
    # First collect all the talk pages
    talk_pages = [BASE_URL]
    doc = open(BASE_URL).read
    Nokogiri::HTML(doc).css('.minioff a').each do |a|
      talk_pages << BASE_DOMAIN + '/zc/' + a['href']
    end
    talk_pages.each do |page|
      parse_page open(page).read
    end
  end

end