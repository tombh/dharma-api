# Base class for spiders
class Spider
  include SpiderLogging

  attr_accessor :talk_fragment, :speaker, :doc
  
  def initialize(start_page = 1)
    @parsed_speakers = [] # Keep track of parsed speakers, so we don't duplicate efforts
    @finished = false
    @page = start_page.to_i
  end

  # Wrapper for fetching the remote html of an individual speaker so we can override it in tests
  def open_speaker_doc(url)
    open(url)
  end

  # Convert a time like 1:34:21 to 5661 (seconds)
  # @time String
  # @return Int
  def colon_time_to_seconds(duration)
    pieces = duration.split(':').reverse
    for i in 0..2
      pieces[i] = 0 if pieces[i] == nil
      pieces[i] = pieces[i].to_i
    end
    pieces[0] + (pieces[1] * 60) + (pieces[2] * 60 * 60)
  end

  # Tidy up large bits of texts like descriptions and bios
  def clean_long_text(text)
    text.gsub(/\s+/, ' ') if text
  end
end