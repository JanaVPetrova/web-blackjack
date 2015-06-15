require File.expand_path('../boot', __FILE__)

env = ENV['RACK_ENV'] || 'development'
Bundler.require(env)

require 'sinatra/base'
require 'slim'
require 'blackjack'

Dir.glob(File.expand_path('app/**/*.rb')).each { |file| require file }

class WebBlackjack < Sinatra::Base
  configure do
    enable :logging
    enable :sessions
    enable :method_override

    log_path = File.expand_path "../../log/#{settings.environment}.log", __FILE__
    file = File.new(log_path, 'a+')
    file.sync = true
    use Rack::CommonLogger, file

    register Blackjack
  end

  set :root, File.expand_path('../', __FILE__)
  set :public_folder, 'public'

  use Games
end
