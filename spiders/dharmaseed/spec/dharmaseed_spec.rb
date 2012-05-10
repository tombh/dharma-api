require_relative './spec_helper'

describe Dharmaseed do
  describe '.scrape_page' do
    before :all do
      doc = open( File.dirname(__FILE__) + '/fixtures/page_sample_with_multitalk.html')
      Dharmaseed.new.scrape_page(doc)      
    end

    it "should find and store the 11 talks in the sample" do
      Talk.all().count.should == 11
    end

    # Even though there are more speakers in the sample the above Dharmaseed.open_speaker_doc()
    # patch always returns the same speaker sample
    it "should find and store the 8 speakers from the samples" do
      Speaker.all().count.should == 8
    end

    after :all do
      Talk.destroy_all()
      Speaker.destroy_all()
    end
  end

  describe '.parse_talk' do
    before :all do
      @doc = open( File.dirname(__FILE__) + '/fixtures/page_sample_with_multitalk.html')
      @spider = Dharmaseed.new
    end

    it "should find and store a talk from a given talklist table" do
      @spider.talk_fragment = Nokogiri::HTML(@doc).css('.talklist table')[0]
      @spider.isolate_table_rows()
      @spider.speaker = Speaker.create({:name => 'test'})
      talk = @spider.parse_talk()
      talk.date.should eq '2012-01-26T00:00:00Z'
      talk.duration.should eq '57:26'
      talk.permalink.should eq "http://dharmaseed.org/teacher/222/talk/15378/20120126-Anushka_Fernandopulle-SR-love_ethics_and_leadership.mp3"
      talk.title.should eq 'Love, Ethics and Leadership'
      talk.venue.should eq 'Spirit Rock Meditation Center'
      talk.event.should eq 'Waking Up As Leaders'
      talk.description.start_with?("Spirit Rock Meditation Center").should be true
    end

  end

  describe '.parse_speaker' do
    before :all do
      @doc = open( File.dirname(__FILE__) + '/fixtures/page_sample_with_multitalk.html')
      @spider = Dharmaseed.new
    end

    it "should find and store the speaker from the speaker sample" do
      # Just take the first talk
      @spider.talk_fragment = Nokogiri::HTML(@doc).css('.talklist table')[0]
      @spider.isolate_table_rows()
      speaker = @spider.parse_speaker
      # This is the name from the the main page, as the spider uses that name rather then the name from the speaker page.
      # And as we've hardcoded the Sayadaw's page as the remote speaker page the name and bio don't match here.
      speaker.name.should eq 'Anushka Fernandopulle' 
      speaker.bio.start_with?('Sayadaw U Tejaniya began his Buddhist training as a young teenager').should be true
      speaker.website.should eq 'http://sayadawutejaniya.org/'
      speaker.picture.should eq 'http://media.dharmaseed.org/uploads/photos/thumb_tejaniya.jpg'
    end

  end

end