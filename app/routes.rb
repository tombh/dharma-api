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
  
  # list all blogs
  get '/speakers' do
  	content_type :json
    @docs = Speaker.all()
    
    @docs.to_json
  end
  
  #view a blog
  get '/show.:id' do |id|
    @doc = Talk.find(id)
    haml :'blog/show', :locals => { :title => "Blog", :blog => @doc}
  end  
  
  # write new blog
  get '/new' do
    haml :'blog/new', :locals => { :title => "New Blog"}
  end  
  
  post '/new' do
    @blog = params[:blog]
    @doc = Talk.new
    @doc.title = @blog[:title]
    @doc.body = @blog[:body]
    if @doc.save
      puts 'Nice Blog'
      redirect '/blogs'
    else
      puts "Error(s): ", @doc.errors.map {|k,v| "#{k}: #{v}"}
      haml :'blog/error', :locals => { :errs => @doc.errors } 
    end
  end
  
  #edit blog
  get '/edit.:id' do |id|
    @doc = Talk.find(id)
    haml :'blog/edit', :locals => { :title => "Edit Blog", :blog => @doc}
  end
  
  put '/edit.:id' do |id|
    @doc = Talk.find(id)
    @doc.update_attributes(params[:blog])
    redirect '/show.'+id
  end
  
  #delete blog
  get '/delete/:id' do |id|
    @doc = Talk.find(id)
    @doc.delete
    redirect '/'
  end
end