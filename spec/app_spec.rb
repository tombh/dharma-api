require_relative './spec_helper'

describe "Dharma API" do

  describe "Homepage" do
    it "should load the home page" do
      get '/'
      last_response.should be_ok
    end
  end

  describe '/talk/:id' do
    it "should return a talk with its speaker" do
    	get '/talk/1'
    	json = JSON.parse(last_response.body)['results'][0]
    	json['title'].should eq 'Advise For Taking Awareness Home'
    	json['description'].start_with?('Insight Meditation Society').should eq true
    	json['duration'].should eq 1433
    	json['event'].should eq "Dhamma Everywhere: Awareness with Wisdom Retreat"
    	json['speaker']['name'].should eq "Sayadaw U Tejaniya"
    	json['speaker']['picture'].should eq 'http://media.dharmaseed.org/uploads/photos/thumb_tejaniya.jpg'
    end
  end

  describe '/speaker/:id' do
    it "should return a speaker with talks" do
    	get '/speaker/2'
    	json = JSON.parse(last_response.body)['results'][0]
    	json['name'].should eq "Thanissara" 
    	json['bio'].start_with?('Thanissara, a practitioner since 1975, was a T').should eq true
    	json['picture'].should eq 'http://media.dharmaseed.org/uploads/photos/thumb_Thanissara_ok.jpg'
    	json['talks'].count eq 1
    end
  end

  describe "/talks" do
    it "should return a page of talks when called without args" do
      get '/talks'
      json = JSON.parse(last_response.body)
      metta = json['metta']
      metta['total'].should eq 5
      results = json['results']
      results.count.should eq 5
    end

    it "should find the talk with 'mountain' in it" do
      get '/talks?search=mountain'
      json = JSON.parse(last_response.body)['results'][0]
      json['permalink'].should eq "http://dharmaseed.org/teacher/178/talk/16074/20120510-Thanissara-DG-3_9_68_icon_of_the_heart.mp3"
    end
  end

  describe "/speakers" do
    it "should return a page of speakers when called without args" do
      get '/speakers'
      json = JSON.parse(last_response.body)
      metta = json['metta']
      metta['total'].should eq 3
      results = json['results']
      results.count.should eq 3
    end
    it "should find the speaker with 'Burma' in their bio" do
      get '/speakers?search=Burma'
      json = JSON.parse(last_response.body)['results'][0]      
      json['name'].should eq "Sayadaw U Tejaniya"
    end
  end

  #TODO spec pagination, ordering and 404s

end