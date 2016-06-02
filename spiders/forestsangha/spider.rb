# forestsanghapublications.org

# Talks given by Theravadin monastics in the Thai forest tradition, usually
# tracing their lineage back through Ajahn Chah.

# Yo so bhagavæ arahaµ sammæsambuddho
# To the Blessed One, the Lord, who fully attained perfect enlightenment
class Forestsangha < Spider
  BASE_DOMAIN = 'https://forestsangha.org/'.freeze
  BASE_URL = BASE_DOMAIN + 'teachings/viewTalk.php?id='
  LICENSE = 'http://creativecommons.org/licenses/by-nc-nd/3.0/'.freeze

  def parse_talk(doc)
    @talk_fragment = doc.at_css('.product-display')

    # There has to be a permalink to a talk
    unless permalink = talk_fragment.tolerant_css('p > a', 'href')
      log.warn "Couldn't get talk's permalink"
      return false
    end

    # Check if it's a link to an external site
    unless permalink.include? 'http://'
      permalink = BASE_DOMAIN + '/' + permalink
    end

    speaker_name = parse_talk_detail('Speaker')

    speaker = Speaker.first_or_create(name: speaker_name)

    talk = Talk.first_or_create(permalink: permalink)

    description = parse_talk_detail('Album')
    title = parse_talk_detail('Title')
    # Sometimes the Album or Title description contains the date
    date = (description + title).scan(/[1-2][0-9][0-9][0-9]/).first
    date = "#{date}/01/01" if date

    talk_details = {
      title: title,
      speaker_id: speaker._id,
      permalink: permalink,
      date: date,
      description: description,
      source: BASE_DOMAIN,
      license: LICENSE
    }

    talk.update_attributes!(talk_details)

    d Talk.find_by_permalink(permalink)
    d "\n"
  end

  def parse_talk_detail(detail)
    @talk_fragment.tolerant_css('div').scan(/#{detail}: (.*)/).first.first.strip
  end

  def run
    d "Crawling Forest Sangha Publications starting on page #{@page}"
    log.info 'Crawl initiated on ' + Time.now.inspect
    # Don't always start from the beginning
    @page = if @recrawl
              0
            else
              # We can use the total number of talks in the DB as a base for where to start
              Talk.where(source: BASE_DOMAIN).count
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
        break if @page > 1200 && empty_talk_count > 10
        next
      end
      parse_talk Nokogiri::HTML(doc_string)
    end
  end
end
