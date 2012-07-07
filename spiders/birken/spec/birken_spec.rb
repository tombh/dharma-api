require_relative './spec_helper'

# Seeing as this is a relative simple spider this test covers both the code and its 
# applicability to the live site it crawls
describe Birken do
  describe '.parse_talk' do

    before :all do
      # Find a specific talk on the page
      Nokogiri::HTML(open(Birken::BASE_URL)).css('ul').each do |ul|
        @ul = ul
        permalink = ul.tolerant_css('li > strong > a', 'href')
        break if permalink.end_with? 'A_Amaro_Birth_Death_and_the_Deathless.mp3'
      end
    end
    
    it 'should correctly find the talk and speaker details' do
      Birken.new.parse_talk @ul
      speaker = Speaker.all()
      talk = Talk.all()
      speaker.count.should eq 1
      speaker = speaker.first
      speaker.name.should eq 'Ajahn Amaro'
      speaker.picture.should eq 'http://mirror1.birken.ca/ajahns/Ajahn_Amaro.jpg'
      talk.count.should eq 1
      talk = talk.first
      talk.license.should eq "http://creativecommons.org/licenses/by-nc-nd/2.5/" 
      talk.permalink.should eq "http://mirror1.birken.ca/dhamma_talks/indiv/Ab-Giri/01/A_Amaro_Birth_Death_and_the_Deathless.mp3"
      talk.source.should eq "http://birken.ca" 
      talk.speaker_id.should eq 1 
      talk.title.should eq "Birth, Death, and the Deathless"
    end
  end 
end