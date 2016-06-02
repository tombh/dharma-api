require_relative './spec_helper'

describe 'Dharma API' do
  # Ideally this would go in the spec_helper but that's shared by the spiders too
  before :all do
    Mail.defaults do
      delivery_method :test # in practice you'd do this in spec_helper.rb
    end

    talks = JSON.parse(open(File.dirname(__FILE__) + '/fixtures/talks.json').read)
    # load talks.json
    talks.each do |talk|
      talk['date'] = talk['date']['$date']
      Talk.create(talk)
    end

    # load speakers.json
    speakers = JSON.parse(open(File.dirname(__FILE__) + '/fixtures/speakers.json').read)
    speakers.each do |speaker|
      Speaker.create(speaker)
    end

    Key.create(
      api_key: '123',
      email: 'mrbuddha@548bc.com',
      status: 'active'
    )

    @auth = '?api_key=123'
  end

  describe 'Authentication' do
    it 'returns a 401 status with no results for an invalid API key' do
      get '/talks' do
        expect(last_response.status).to eq 401
        json = JSON.parse(last_response.body)
        expect(json['results'].count).to be <= 1
      end
    end
  end

  describe 'Homepage' do
    it 'loads the home page' do
      get '/'
      expect(last_response.status).to eq 200
    end
  end

  describe '/talk/:id' do
    it 'returns a talk with its speaker' do
      get '/talk/1' + @auth
      json = JSON.parse(last_response.body)['results'][0]
      expect(json['id']).to eq 1
      expect(json['title']).to eq 'How Does the Heart Let Go?'
      expect(json['description']).to start_with('Being with things as they are and letting')
      expect(json['duration']).to eq 3032
      expect(json['event']).to eq nil
      expect(json['speaker']['name']).to eq 'Mary Grace Orr'
      expect(json['speaker']['picture']).to eq 'http://media.dharmaseed.org/uploads/photos/thumb_13589%20C%20Mary.jpg'
      expect(json['source']).to eq 'http://dharmaseed.org'
      expect(json['license']).to eq 'http://creativecommons.org/licenses/by-nc-nd/3.0/'
    end
  end

  describe '/speaker/:id' do
    it 'returns a speaker with talks' do
      get '/speaker/2' + @auth
      json = JSON.parse(last_response.body)['results'][0]
      expect(json['name']).to eq 'Jack Kornfield'
      expect(json['bio']).to start_with("Over the years of teaching, I've found a growing need")
      expect(json['picture']).to eq 'http://media.dharmaseed.org/uploads/photos/thumb_jack_kornfield.jpg'
      expect(json['talks'].count).to eq 1
    end
  end

  describe '/talks' do
    it 'returns a page of talks when called without args' do
      get '/talks' + @auth
      json = JSON.parse(last_response.body)
      metta = json['metta']
      expect(metta['total']).to eq 29
      results = json['results']
      expect(results.count).to eq 25
    end

    it "finds the talk with 'mountain' in it" do
      get "/talks#{@auth}&search=mountain"
      json = JSON.parse(last_response.body)['results'][0]
      expect(json['permalink']).to eq(
        'http://dharmaseed.org/teacher/178/talk/16074/20120510-Thanissara-DG-3_9_68_icon_of_the_heart.mp3'
      )
    end
  end

  describe '/speakers' do
    it 'returns a page of speakers when called without args' do
      get '/speakers' + @auth
      json = JSON.parse(last_response.body)
      metta = json['metta']
      expect(metta['total']).to eq 11
      results = json['results']
      expect(results.count).to eq 11
    end

    it "finds the speaker with 'Zen Hospice' in their bio" do
      get "/speakers#{@auth}&search=Zen%20Hospice"
      json = JSON.parse(last_response.body)['results'][0]
      expect(json['name']).to eq 'David Cohn'
    end
  end

  # TODO: spec pagination, ordering and 404s

  describe 'API key manager' do
    include Mail::Matchers

    describe '/request_api_key' do
      before :all do
        Mail::TestMailer.deliveries.clear
        @email = 'sample@somewhere.com'
        get '/request_api_key?email=' + @email
      end

      it 'generates API key' do
        expect(last_response.status).to eq 200
        @api_key = Key.find_by(email: @email).api_key
        expect(@api_key).not_to be_empty
      end

      it { should have_sent_email.to(@email) }
      it { should have_sent_email.matching_body(/#{@api_key}/) }
    end
  end
end
