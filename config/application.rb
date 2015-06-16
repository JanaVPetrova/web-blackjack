require File.expand_path('../boot', __FILE__)

env = ENV['RACK_ENV'] || 'development'
Bundler.require(env)

require 'sinatra/base'
require 'slim'
require 'blackjack'

Dir.glob(File.expand_path('app/**/*.rb')).each { |file| require file }

class WebBlackjack < Sinatra::Base
  configure do
    enable :sessions
    enable :method_override

    register Blackjack
  end

  set :root, File.expand_path('../', __FILE__)
  set :public_folder, 'public'

  use Games
end
