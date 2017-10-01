#\ -p 4567 -o 0.0.0.0

require 'sinatra'
require 'rack/reloader'
require './api.rb'

set :environment, :development

configure :development do
  enable :raise_errors
  enable :show_exceptions
end

use Rack::Reloader, 0 if development?

map '/' do
  run Sinatra::Application
end

