class Dharma < Sinatra::Base
  # directory path settings relative to app file

  set :app_path, '/'
  set :root, File.join(File.dirname(__FILE__), '.')
  set :public_folder, Proc.new { File.join(root, 'public') }
  set :method_override, true
  
  def initialize
    super
  end

  before do
    content_type :json
  end

  # You can order by a field, by putting a '-' at the beginning for desc
  # and leaving it normal for asc
  def create_order(default = '-date', valid_fields = {})
    @direction = 'asc'
    @order = params.fetch('order', default)
    if @order[0] == '-'
      @order.gsub!('-', '')
      @direction = 'desc'
    end
  end

  def pagination
    {
      :order    => @order.to_sym.send(@direction.to_sym),
      :per_page => 25, 
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
          {:description => /#{query}/i}
        ]
      }
    else
      where = {}
    end
    return where
  end

  def respond value
    value.empty? ? 404 : value.to_json
  end

  get '/' do
    "Le Dharma API".to_json
  end
  
  # list all speakers
  get '/speakers' do    
    create_order default = 'id'
    respond Speaker.where(search_helper).paginate(pagination)
  end

  # list all talks
  get '/talks' do
    create_order
    respond Talk.where(search_helper).paginate(pagination)
  end

  # list individual talk with its arent speaker
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
    "Ouch: dukkha".to_json
  end

  not_found do
    "404: sunyata".to_json
  end
  
end