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
      speaker = Speaker.all
      talk = Talk.all
      expect(speaker.count).to eq 1
      speaker = speaker.first
      expect(speaker.name).to eq 'Ajahn Amaro'
      expect(speaker.picture).to eq 'http://mirror1.birken.ca/ajahns/Ajahn_Amaro.jpg'
      expect(talk.count).to eq 1
      talk = talk.first
      expect(talk.duration).to eq 3002
      expect(talk.license).to eq 'http://creativecommons.org/licenses/by-nc-nd/2.5/'
      expect(talk.permalink).to eq 'http://mirror1.birken.ca/dhamma_talks/indiv/Ab-Giri/01/A_Amaro_Birth_Death_and_the_Deathless.mp3'
      expect(talk.source).to eq 'http://birken.ca'
      expect(talk.title).to eq 'Birth, Death, and the Deathless'
    end
  end
end
