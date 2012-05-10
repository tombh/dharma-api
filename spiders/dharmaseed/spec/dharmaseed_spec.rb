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

  end
end