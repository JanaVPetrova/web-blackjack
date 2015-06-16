class Games < Sinatra::Base
  set :root, File.expand_path('../../', __FILE__)

  helpers do
    def save_to_session(data = {})
      session[:data] ||= {}
      session[:data].merge! data
    end

    def count_prize(hands)
      hands.inject(0) { |sum, hand| sum += (hand.result == 'win' ? 1.5 * hand.bet : 0)  }
    end
  end

  before do
    session[:flash] = nil
  end

  get '/' do
    @player = Blackjack::Player.new(1000)

    data = {
      player: @player
    }

    save_to_session data

    slim :'games/new'
  end

  get '/games/new' do
    @player = session[:data][:player]

    slim :'games/new'
  end

  post '/games' do
    last_game = session[:data][:game]
    deck = last_game.deck if last_game && last_game.deck.length > 4

    @game = Blackjack::Game.new(deck: deck)
    @player = session[:data][:player]

    if params[:bet].to_i <= @player.balance
      @player.balance -= params[:bet].to_i

      hand = Blackjack::Hand.new(@game.select_card(2), params[:bet].to_i)
      @game.hands << hand

      data = {
        game: @game,
        player: @player
      }

      save_to_session data

      slim  :'games/game'
    else
      session[:flash] = 'No money, no honey'

      slim :'games/new'
    end
  end

  put '/games/hands/:id/split' do
    @game = session[:data][:game]
    @player = session[:data][:player]

    id = params[:id].to_i

    if @player.balance >= @game.hands[id].bet
      hand = @game.hands.delete_at id
      hands = @game.split(hand)
      @game.hands = @game.hands + hands
      @player.balance -= hand.bet

      data = {
        game: @game,
        player: @player
      }

      save_to_session data
    else
      session[:flash] = 'No money, no honey'
    end

    slim :'/games/game'
  end

  put '/games/hands/:id/double' do
    @game = session[:data][:game]
    @player = session[:data][:player]

    id = params[:id].to_i

    if @player.balance >= @game.hands[id].bet
      @player.balance -= @game.hands[id].bet
      @game.hands[id].double

      data = {
        game: @game
      }

      save_to_session data
    else
      session[:flash] = 'No money, no honey'
    end

    slim :'/games/game'
  end

  put '/games/hands/:id/hit' do
    @game = session[:data][:game]
    @player = session[:data][:player]

    if @game.deck.any?
      id = params[:id].to_i
      @game.hit @game.hands[id]

      data = {
        game: @game
      }

      save_to_session data
    else
      session[:flash] = 'No more cards, sorry!'
    end

    slim :'/games/game'
  end

  put '/games/hands/:id/stand' do
    @game = session[:data][:game]
    @player = session[:data][:player]

    id = params[:id].to_i
    @game.hands[id].stand

    if @game.over?
      @game.boost
      @game.check
      @game.dealer.show
      @player.balance += count_prize(@game.hands)
    end

    data = {
      game: @game,
      player: @player
    }

    save_to_session data

    slim :'/games/game'
  end
end
