require_relative './spec_helper'

# Seeing as this is a relative simple spider this test covers both the code and its 
# applicability to the live site it crawls
describe Forestsangha do
  describe '.parse_talk' do
    it 'should correctly find the talk and speaker details from the sample URL (viewTalk.php?id=1223)' do
      doc = open('http://forestsanghapublications.org/viewTalk.php?id=1223')
      Forestsangha.new.parse_talk Nokogiri::HTML(doc)
      speaker = Speaker.all()
      talk = Talk.all()
      speaker.count.should eq 1
      speaker = speaker.first
      speaker.name.should eq 'Ajahn Sucitto'
      talk.count.should eq 1
      talk = talk.first
      talk.license.should eq "http://creativecommons.org/licenses/by-nc-nd/3.0/" 
      talk.permalink.should eq "http://forestsanghapublications.org/assets/audio/Ajahn_Sucitto/Ajahn_Sucitto_-_Pause_for_the_Deathless_-_Vesak_2011_-_rec2011-05-28.mp3"
      talk.source.should eq "http://forestsanghapublications.org" 
      talk.speaker_id.should eq 1 
      talk.title.should eq "Pause for the Deathless - Vesak 2011"
      talk.date.to_s.should eq "2011-01-01"
    end
  end 
end