class Dharma < Sinatra::Base
  # directory path settings relative to app file

  set :app_path, '/'
  set :root, File.join(File.dirname(__FILE__), '.')
  set :public_folder, Proc.new { File.join(root, 'public') }
  set :method_override, true
  
  def initialize
    super
  end

  get '/' do
    "Le Dharma API"
  end
  
  # list all speakers
  get '/speakers' do
    content_type :json
    @docs = Speaker.all()    
    @docs.to_json    
  end

  # list all talks
  get '/talks' do
    content_type :json
    @docs = Talk.all()    
    @docs.to_json
  end  
  
end