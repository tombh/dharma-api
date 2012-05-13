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

  def respond value
    value.empty? ? 404 : value.to_json
  end

  get '/' do
    "Le Dharma API".to_json
  end
  
  # list all speakers
  get '/speakers' do
    create_order default = 'id'
    respond Speaker.paginate(pagination)
  end

  # list all talks
  get '/talks' do
    create_order
    respond Talk.paginate(pagination)
  end

  # list indivdual talk
  get '/talk/:id' do
    talk = Talk.where(:id => params[:id].to_i).first
    !talk and return 404
    talk = talk.serializable_hash
    talk['speaker'] = Speaker.find_by_id(talk['speaker_id'])
    talk.delete('speaker_id')
    respond talk
  end

  # list indivdual speaker
  get '/speaker/:id' do
    respond Speaker.where(:id => params[:id].to_i)
  end

  error do
    "Ouch".to_json
  end

  not_found do
    "404: sunyata".to_json
  end
  
end