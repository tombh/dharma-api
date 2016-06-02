require_relative './spec_helper'

# Seeing as this is a relative simple spider this test covers both the code and its
# applicability to the live site it crawls
describe Sfzc do
  describe '.parse_talk' do
    it 'should correctly find the talk and speaker details from URL (display.asp?catid=1,10&pageid=3125)' do
      pending 'SFZC has changed their HTML layout'
      Sfzc.new.parse_page open('http://www.sfzc.org/zc/display.asp?catid=1,10&pageid=3125').read
      speaker = Speaker.order(:name.asc)
      talk = Talk.order(:date.desc)
      speaker.count.should eq 60
      speaker = speaker.first
      speaker.name.should eq 'Alan Senauke'
      talk.count.should eq 234
      talk = talk.first
      talk.license.should eq Sfzc::LICENSE
      talk.source.should eq Sfzc::BASE_DOMAIN
      talk.permalink.should eq 'http://media.sfzc.org/mp3/2011/2011-12-31-cc-wendy-lewis.mp3'
      talk.speaker_id.should eq 1
      talk.title.should eq 'Ethics and Community'
      talk.date.to_s.should eq '2011-12-31'
    end
  end
end
