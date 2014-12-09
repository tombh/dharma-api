require_relative './spec_helper'

describe "Dharma API" do

  # Ideally this would go in the spec_helper but that's shared by the spiders too
  before :all do
    Mail.defaults do
      delivery_method :test # in practice you'd do this in spec_helper.rb
    end

    talks = JSON.parse(open(File.dirname(__FILE__) + '/fixtures/talks.json').read)
    # load talks.json
    talks.each do |talk|
      Talk.create(talk)
    end

    # load speakers.json
    speakers = JSON.parse(open(File.dirname(__FILE__) + '/fixtures/speakers.json').read)
    speakers.each do |speaker|
      Speaker.create(speaker)
    end

    Key.create({
      :api_key => '123',
      :email => 'mrbuddha@548bc.com',
      :status => 'active'
    })

    @auth = '?api_key=123'
  end

  describe "Authentication" do
    it "should return a 401 status with no results for an invalid API key" do
      get '/talks' do
        last_response.status.should be 401
        json = JSON.parse(last_response.body)
        json['results'].count.should <= 1
      end
    end
  end

  describe "Homepage" do
    it "should load the home page" do
      get '/'
      last_response.should be_ok
    end
  end

  describe '/talk/:id' do
    it "should return a talk with its speaker" do
    	get '/talk/1' + @auth
    	json = JSON.parse(last_response.body)['results'][0]
    	json['title'].should eq 'How Does the Heart Let Go?'
    	json['description'].start_with?('Being with things as they are and letting').should eq true
    	json['duration'].should eq 3032
    	json['event'].should eq nil
    	json['speaker']['name'].should eq "Mary Grace Orr"
    	json['speaker']['picture'].should eq 'http://media.dharmaseed.org/uploads/photos/thumb_13589%20C%20Mary.jpg'
      json['source'].should eq 'http://dharmaseed.org'
      json['license'].should eq 'http://creativecommons.org/licenses/by-nc-nd/3.0/'
    end
  end

  describe '/speaker/:id' do
    it "should return a speaker with talks" do
    	get '/speaker/2' + @auth
    	json = JSON.parse(last_response.body)['results'][0]
    	json['name'].should eq "Jack Kornfield"
    	json['bio'].start_with?("Over the years of teaching, I've found a growing need").should eq true
    	json['picture'].should eq 'http://media.dharmaseed.org/uploads/photos/thumb_jack_kornfield.jpg'
    	json['talks'].count eq 1
    end
  end

  describe "/talks" do
    it "should return a page of talks when called without args" do
      get '/talks' + @auth
      json = JSON.parse(last_response.body)
      metta = json['metta']
      metta['total'].should eq 29
      results = json['results']
      results.count.should eq 25
    end

    it "should find the talk with 'mountain' in it" do
      get "/talks#{@auth}&search=mountain"
      json = JSON.parse(last_response.body)['results'][0]
      json['permalink'].should eq "http://dharmaseed.org/teacher/178/talk/16074/20120510-Thanissara-DG-3_9_68_icon_of_the_heart.mp3"
    end
  end

  describe "/speakers" do
    it "should return a page of speakers when called without args" do
      get '/speakers' + @auth
      json = JSON.parse(last_response.body)
      metta = json['metta']
      metta['total'].should eq 11
      results = json['results']
      results.count.should eq 11
    end
    it "should find the speaker with 'Zen Hospice' in their bio" do
      get "/speakers#{@auth}&search=Zen%20Hospice"
      json = JSON.parse(last_response.body)['results'][0]
      json['name'].should eq "David Cohn"
    end
  end

  #TODO spec pagination, ordering and 404s

  describe "API key manager" do

    include Mail::Matchers

    describe "/request_api_key" do
      before :all do
        Mail::TestMailer.deliveries.clear
        @email = "sample@somewhere.com"
        get "/request_api_key?email=" + @email
      end

      it "should send an email with an API key in it" do
        last_response.status.should be 200
        @api_key = Key.find_by_email(@email).api_key
        @api_key.empty?.should_not eq true
        should have_sent_email.to(@email)
        should have_sent_email.matching_body(/#{@api_key}/)
      end
    end

  end

end