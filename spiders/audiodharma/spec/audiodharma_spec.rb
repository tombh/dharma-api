require_relative './spec_helper'

describe Audiodharma do
  describe '.scrape_page' do
    before :all do
      doc = open(File.dirname(__FILE__) + '/fixtures/page_sample_with_multitalk.html')
      Audiodharma.new(recrawl: true).scrape_page(doc)
    end

    it 'should find and store the 101 talks in the sample' do
      expect(Talk.all.count).to eq 101
    end

    # Even though there are more speakers in the sample the above Dharmaseed.open_speaker_doc()
    # patch always returns the same speaker sample
    it 'should find and store the 17 speakers from the samples' do
      expect(Speaker.all.count).to eq 17
    end
    after :all do
      Talk.destroy_all
      Speaker.destroy_all
    end
  end

  describe '.parse_talk' do
    before :all do
      @doc = open(File.dirname(__FILE__) + '/fixtures/page_sample_with_multitalk.html')
      @spider = Audiodharma.new(recrawl: true)
    end

    it 'should find and store a talk from a given talklist table' do
      @spider.talk_fragment = @spider.talks(@doc).first
      @spider.speaker = Speaker.create(name: 'test')
      talk = @spider.parse_talk
      expect(talk.date.to_s).to eq '2012-05-13'
      expect(talk.duration).to eq 2260
      expect(talk.permalink).to eq(
        'http://audiodharma.org/teacher/1/talk/3042/venue/IMC/20120513-Gil_Fronsdal-IMC-contexts_of_mindfulness_practice.mp3'
      )
      expect(talk.title).to eq 'Contexts of Mindfulness Practice'
      expect(talk.venue).to eq 'Insight Meditation Centre, Redwood, California'
      expect(talk.event).to eq nil
      expect(talk.description.start_with?('How the different approaches to teaching and applying')).to be true
    end
  end

  describe '.parse_speaker' do
    before :all do
      @doc = open(File.dirname(__FILE__) + '/fixtures/page_sample_with_multitalk.html')
      @spider = Audiodharma.new(recrawl: true)
    end

    it 'should find and store the speaker from the speaker sample' do
      # Just take the first talk
      @spider.talk_fragment = Nokogiri::HTML(@doc)
      speaker = @spider.parse_speaker
      # This is the name from the the main page, as the spider uses that name rather then the name from the speaker page.
      # And as we've hardcoded the Thanisarro's page as the remote speaker page the name and bio don't match here.
      expect(speaker.name).to eq 'Gil Fronsdal'
      expect(speaker.bio.start_with?('Thanissaro Bhikkhu (Geoffrey DeGraff) is an American monk')).to be true
      expect(speaker.website).to eq 'http://www.watmetta.org/'
      expect(speaker.picture).to eq 'http://media.audiodharma.org/uploads/photos/thumb_s108902769133839_1858.jpg'
    end
  end

  # You can skip out these slower remote test with `rspec --tag ~@depends_on_remote [specs]'
  # Test to see whether the live site has changed to the extent that we're no longer getting any talks or speakers on a crawl
  describe 'Scrapability of current live site', depends_on_remote: true do
    before :all do
      Speaker.destroy_all
      Talk.destroy_all
      doc = open(Audiodharma::BASE_URL + '1')
      @spider = Audiodharma.new(recrawl: true)
      @spider.talk_fragment = @spider.talks(doc).first
      @spider.parse_speaker
      @spider.parse_talk
    end

    it 'should find at least 1 talk from the first crawled page' do
      expect(Talk.all.count).to be > 0
    end

    it 'should find at least 1 speaker from the first crawled page' do
      expect(Speaker.all.count).to be > 0
    end
  end
end
