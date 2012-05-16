# encoding: utf-8

class Dharma < Sinatra::Base

  set :app_path, '/'
  set :root, File.join(File.dirname(__FILE__), '..')
  set :public_folder, Proc.new { File.join(root, 'public') }
  set :method_override, true
  
  def initialize
    super
  end

  before do
    content_type :json
  end

  def order_helper(default = '-date')
    # You can order by a field, by putting a '-' at the beginning for desc
    # and leaving it normal for asc
    @direction = 'asc'
    @order = params.fetch('order', default)
    if @order[0] == '-'
      @order.gsub!('-', '')
      @direction = 'desc'
    end
    { @order.to_sym => @direction }
  end

  def pagination_helper()
    @rpp = params['rpp'] ? params['rpp'].to_i : 25    
    {
      :per_page => @rpp, 
      :page     => params['page'],
    }
  end

  # I know it searches fields that aren't necessarily in the current model,
  # but mongo's pretty forgiving.
  def search_helper
    query = params['search']
    if query
      where = {
        '$or' => [
          {:name => /#{query}/i},
          {:bio => /#{query}/i},
          {:title => /#{query}/i},
          {:description => /#{query}/i},
          {:permalink => /#{query}/i}
        ]
      }
    else
      where = {}
    end
    where
  end

  def respond body
    return 404 if !body || body.empty?
    answer = {}
    if body.kind_of? Array
      answer['metta'] = {}
      answer['metta']['total'] = @total
      answer['metta']['results_per_page'] = @rpp
      answer['metta']['ordered_by'] = @order + " " + @direction
      answer['metta']['loving_kindness'] = true
    else
      body = [body]
    end
    answer['results'] = body
    answer = answer.to_json
    if params['callback']
      answer = "#{params['callback']}(#{answer})"
    end
    answer
  end

  get '/' do
    respond "Le Dharma API"
  end
  
  # query all speakers
  get '/speakers' do
    speakers = Speaker.where(search_helper)
    @total = speakers.count 
    respond speakers
      .order(order_helper default = 'id')
      .paginate(pagination_helper)
  end

  # query all talks
  get '/talks' do
    talks = Talk.where(search_helper)
    @total = talks.count
    respond talks
      .order(order_helper)
      .paginate(pagination_helper)
  end

  # list individual talk with its parent speaker
  get '/talk/:id' do
    talk = Talk.where(:id => params[:id].to_i).first
    !talk and return 404
    talk_hash = talk.serializable_hash
    talk_hash['speaker'] = talk.speaker
    talk_hash.delete('speaker_id')
    respond talk_hash
  end

  # list individual speaker with all their talks
  get '/speaker/:id' do
    speaker = Speaker.where(:id => params[:id].to_i).first
    !speaker and return 404
    speaker_hash = speaker.serializable_hash
    speaker_hash['talks'] = speaker.talks
    respond speaker_hash
  end

  error do
    respond "Ouch: duḥkha"
  end

  not_found do
    respond "404: śūnyatā"
  end
  
end