require_relative './spec_helper'

describe Audiodharma do
  describe '.scrape_page' do
    before :all do
      doc = open( File.dirname(__FILE__) + '/fixtures/page_sample_with_multitalk.html')
      Audiodharma.new(:recrawl => true).scrape_page(doc)
    end

    it "should find and store the 149 talks in the sample" do
      Talk.all().count.should == 154
    end

    # Even though there are more speakers in the sample the above Dharmaseed.open_speaker_doc()
    # patch always returns the same speaker sample
    it "should find and store the 17 speakers from the samples" do
      Speaker.all().count.should == 20
    end
    after :all do
      Talk.destroy_all()
      Speaker.destroy_all()
    end
  end

  describe '.parse_talk' do
    before :all do
      @doc = open( File.dirname(__FILE__) + '/fixtures/page_sample_with_multitalk.html')
      @spider = Audiodharma.new(:recrawl => true)
    end

    it "should find and store a talk from a given talklist table" do
      @spider.talk_fragment = @spider.talks(@doc).first
      @spider.speaker = Speaker.create({:name => 'test'})
      talk = @spider.parse_talk()
      talk.date.to_s.should eq '2012-05-13'
      talk.duration.should eq 2260
      talk.permalink.should eq "http://audiodharma.org/teacher/1/talk/3042/venue/IMC/20120513-Gil_Fronsdal-IMC-contexts_of_mindfulness_practice.mp3"
      talk.title.should eq 'Contexts of Mindfulness Practice'
      talk.venue.should eq 'Insight Meditation Centre, Redwood, California'
      talk.event.should eq nil
      talk.description.start_with?("How the different approaches to teaching and applying").should be true
    end

  end

  describe '.parse_speaker' do
    before :all do
      @doc = open( File.dirname(__FILE__) + '/fixtures/page_sample_with_multitalk.html')
      @spider = Audiodharma.new(:recrawl => true)
    end

    it "should find and store the speaker from the speaker sample" do
      # Just take the first talk
      @spider.talk_fragment = Nokogiri::HTML(@doc)
      speaker = @spider.parse_speaker()
      # This is the name from the the main page, as the spider uses that name rather then the name from the speaker page.
      # And as we've hardcoded the Thanisarro's page as the remote speaker page the name and bio don't match here.
      speaker.name.should eq 'Gil Fronsdal' 
      speaker.bio.start_with?('Thanissaro Bhikkhu (Geoffrey DeGraff) is an American monk').should be true
      speaker.website.should eq 'http://www.watmetta.org/'
      speaker.picture.should eq 'http://media.audiodharma.org/uploads/photos/thumb_s108902769133839_1858.jpg'
    end

  end

  # You can skip out these slower remote test with `rspec --tag ~@depends_on_remote [specs]'  
  # Test to see whether the live site has changed to the extent that we're no longer getting any talks or speakers on a crawl
  describe 'Scrapability of current live site', :depends_on_remote => true do
    
    before :all do
      Speaker.destroy_all()
      Talk.destroy_all()
      doc = open( Audiodharma::BASE_URL + "1" )
      @spider = Audiodharma.new(:recrawl => true)
      @spider.talk_fragment = @spider.talks(doc).first
      @spider.parse_speaker()
      @spider.parse_talk()
    end

    it 'should find at least 1 talk from the first crawled page' do
      Talk.all().count.should > 0
    end

    it 'should find at least 1 speaker from the first crawled page' do
      Speaker.all().count.should > 0
    end
  end

end