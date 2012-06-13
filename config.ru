require './app/init'
require './app/routes'

# Allow cross-domain AJAX calls
use Rack::Cors do
  allow do
    origins '*'
    resource '*', :headers => :any, :methods => :any
  end
end

run Dharma