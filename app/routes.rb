# encoding: utf-8
require 'lib/api_helpers'

# Base Sinatra class
class Dharma < Sinatra::Base
  include APIPHelpers

  set :app_path, '/'
  set :root, File.join(File.dirname(__FILE__), '.')
  set :public_folder, proc { File.join(root, 'public') }
  set :method_override, true
  set :protection, except: :json_csrf

  def initialize
    super
  end

  before do
    content_type :json
  end

  get '/' do
    content_type :html
    erb markdown(File.open(PROJECT_ROOT + '/README.md').read)
  end

  # query all speakers
  get '/speakers' do
    auth
    speakers = Speaker.where(search_helper)
    @total = speakers.count
    respond(
      speakers.order_by(order_helper)
              .limit(limit_helper)
              .skip(skip_helper)
    )
  end

  # query all talks
  get '/talks' do
    auth
    talks = Talk.where(search_helper)
    @total = talks.count
    respond(
      talks.includes(:speaker)
           .order_by(order_helper)
           .limit(limit_helper)
           .skip(skip_helper)
    )
  end

  # list individual talk with its parent speaker
  get '/talk/:id' do
    auth
    talk = Talk.where(id: params[:id].to_i).first
    return 404 unless talk
    talk_hash = talk.serializable_hash
    talk_hash['speaker'] = talk.speaker
    talk_hash.delete('speaker_id')
    respond talk_hash
  end

  # list individual speaker with all their talks
  get '/speaker/:id' do
    auth
    speaker = Speaker.where(id: params[:id].to_i).first
    return 404 unless speaker
    speaker_hash = speaker.serializable_hash
    speaker_hash['talks'] = speaker.talks
    respond speaker_hash
  end

  get '/request_api_key' do
    if !params['email']
      respond 'Please provide an email address'
    elsif Key.email_token(params['email'])
      respond 'Verification mail sent'
    else
      status 500
      respond "Couldn't send email"
    end
  end

  error 401 do
    if !params['api_key']
      respond "You didn't give me your API key"
    else
      respond 'Invalid API key. \n You shall not pass! http://www.youtube.com/watch?v=V4UfAL9f74I'
    end
  end

  error do
    respond "Ouch: duḥkha"
  end

  not_found do
    respond "404: śūnyatā"
  end
end
