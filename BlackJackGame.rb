require 'BlackJackIO'
require 'Shoe'
require 'Player'
require 'Dealer'
require 'Hand'
require 'DealerHand'

# = Description
#
# This class represents the entire BlackJack game.  This is not a single
# round, but the entire game until the user exits.  This game flow and calls
# BlackJackIO for user Input/Output.
#
# = Synopsis
# 
#   game = BlackJackGame.new
#   game.debug = True|False
#   game.play_god = True|False
#   game.play
# 
# = Author
#
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

class BlackJackGame
  # BlackJack pays 3 to 2 in most casinos.
  BLACKJACK_PAYS = 1.5
  # Insurance pays 2 to 1 in most casinos.
  INSURANCE_PAYS = 2

  # Set debug to True if you want to see the shoe and the Dealer's hand.
  attr_accessor :debug
  # Set play_god to True if you want to set which cards each player gets.
  attr_accessor :play_god
  # Other game options
  attr_accessor :max_players, :min_bet, :max_bet, :bet_increment, \
    :bankroll, :hit_soft_17, :even_money_offered

  # This method initializes variables, sets default game options
  # and creates the GameIO object.
  def initialize
    @shoe = @player_cnt = @dealer = nil
    @num_rounds = @num_shoes = 0
    @num_decks = 1
    @max_players = 4
    @min_bet = 1
    @max_bet = 100
    @bet_increment = 1
    @bankroll = 1000
    @hit_soft_17 = nil
    @even_money_offered = 1 # Hate when casinos don't offer this option
    @players = []
    @broke_players = []
    @io = BlackJackIO.new
  end

  # This method is the meat of the game.  It handles all game play until
  # there are no more players or the user quits.
  #   Get all input parameters to start game
  #   While user want to play another shoe
  #     Create, shuffle and cut shoe
  #     While the shoe can be played
  #       Start Round [IO]
  #       Place Bets
  #       Deal Round
  #       Show Hands [IO]
  #       Play Round
  #       Settle Round
  #     end
  #   end
  #   Show Game Results [IO]
  def play
    # round_started used to determine if we need to settle bets
    # if the user quits mid-game.
    @round_started = nil
    catch :quit do
      init_game

      want_to_play = 1
      while want_to_play

        # Create and shuffle Shoe
        @shoe = Shoe.new(@num_decks)
        @shoe.shuffle

        # Player can cut the shoe, pick a random one (excluding dealer)
        @io.show_shoe(@shoe) if @debug
        cut_at = @io.cut_shoe(@shoe, @players[ rand(@players.length - 1) ])
        @shoe.cut(cut_at)
        while @shoe.can_play(@players.length)
          @io.start_round(@players, @num_shoes + 1, @num_rounds + 1)
          @io.show_shoe(@shoe) if @debug
          place_your_bets
          @round_started = 1 # Round is considered started after bets are in
          deal_round
          @io.show_hands(@players) if @debug
          handle_insurance if @dealer.hand.up_card.is_ace
          play_round unless @dealer.hand.is_bj
          settle_round
          @num_rounds += 1
          @round_started = nil
        end

        @num_shoes += 1
        want_to_play = @io.want_to_play(@num_shoes)
      end
    end
    if @shoe
      settle_round if @round_started
      @io.show_game_results(@broke_players + @players, @num_rounds, @num_shoes)
    end
    @io.quit
  end

  # This method returns true if at least one player needs to change their bet
  # because their bet exceeds their bankroll.
  def need_bet_change
    result = nil
    for player in @players
      if player.bet > player.bankroll and not player.is_dealer
        @io.need_to_change_bet(player)
        result = 1
      end
    end
    return result
  end

  # This method's job is to:
  # 1. Display welcome msg
  # 2. Get number of decks
  # 3. Get number of players
  # 4. Get player names
  # 5. Create the player objects, add them to the players array
  # 6. Create the Dealer object and add him to the players array
  def init_game
    @io.welcome_msg
    @num_decks = @io.get_num_decks 
    @player_cnt = @io.get_player_cnt(@max_players)
    players_names = @io.get_players_names

    # Initialize player objects
    0.upto(players_names.length - 1) do |x|
      @players[x] = Player.new(players_names[x], @bankroll)
    end

    # Create the dealer and add as a player
    @dealer = Dealer.new
    @dealer.hit_soft_17 = @hit_soft_17
    @players[@players.length] = @dealer
  end

  # This method handles players placing their bets and creates the Hand.
  def place_your_bets
    # Check to see if we need to ask for bet sizes
    if @num_rounds == 0 or need_bet_change or @io.change_bet_sizes
      @io.get_players_bet_sizes(@players, @min_bet, @max_bet, @bet_increment)
    end

    for player in @players
      player.start_hand
    end
  end

  # This method deals the initial round of BlackJack, including dealer.
  def deal_round
    for player in @players
      cards = []
      if @play_god
        cards = @io.set_hand(@shoe, player)
      else
        cards = @shoe.deal_hand(@players.index(player), @players.length)
      end
      player.hands[0].deal(cards)
    end
  end

  # This method handles insurance and even money when the dealer's up card
  # is an ace.
  def handle_insurance
    # Show dealer's hand first
    @io.show_dealers_up_card(@dealer)

    # Get insurance and even money bets
    for player in @players
      next if player.is_dealer
      hand = player.hands[0]
      if player.can_afford_insurance or (hand.is_bj and @even_money_offered)
        result = @io.player_want_insurance(player, @even_money_offered)
        case result
        when "y"
          insurance_bet = player.bet.to_f / 2
          player.place_insurance_bet(hand, insurance_bet)
          @io.player_places_insurance_bet(player, hand)
        when "e"
          hand.is_even_money = 1 if hand.is_bj
          hand.stand
        end
      end
    end

    # Settle insurance bets (even money bets settled later)
    for player in @players
      next if player.is_dealer
      hand = player.hands[0]
      if hand.insurance_bet > 0
        if @dealer.hand.is_bj
          # Dealer action first, player sets insuranceBet back to 0
          @dealer.pay(hand.insurance_bet * INSURANCE_PAYS)
          player.win_insurance_bet(hand, (hand.insurance_bet * \
                                          INSURANCE_PAYS) + hand.insurance_bet)
          @io.player_wins_insurance(player)
        else
          # Dealer action first, player sets insuranceBet back to 0
          @dealer.win_bet(hand.insurance_bet)
          player.lose_insurance_bet(hand)
          @io.player_loses_insurance(player)
        end
      end
    end
  end

  # This method handles playing out the round of BlackJack.
  def play_round
    for player in @players
      for hand in player.hands
        # Check for split from previous hand
        if hand.cards.length == 1 and hand.is_split
          hit_split_hand(player, hand)
        end

        if player.is_dealer and not @play_god
          hand.play(@shoe)
        else
          while hand.can_hit and not hand.is_done
            move = @io.get_players_move(@dealer, player, hand)
            case move
            when "h" # Hit
              hit_hand(player, hand)
            when "d" # Double down
              hit_hand(player, hand)
              player.double_bet(hand)
              hand.stand
            when "t" # Stand
              hand.stand
            when "p" # Split
              player.split_hand(hand)
              @io.show_hands(player)
              hit_split_hand(player, hand)
            when "g" # play_god mode, let god.super decide
              if player.is_dealer and @play_god
                hand.play(@shoe)
              else
                @io.try_again
              end
            else
              # Invalid result
              @io.try_again
            end
          end
        end
        @io.show_hand(player, hand)
      end
    end
  end

  # This method takes care of a player hitting a hand.  It deals with the
  # fact that we may in god mode and allow the user to pick the card.
  def hit_hand(player, hand)
    card = nil
    if @play_god
      card = @io.set_card(@shoe, player, nil)
    else
      card = @shoe.deal_card
    end
    hand.hit(card)
  end

  # This method takes card of hitting a split hand.  It deals with the
  # rules of split hands:
  # 1. You can only split so many hands, determined by player.has_max_hands
  # 2. When you split aces, you only get one more card, unless it too is an ace
  def hit_split_hand(player, hand)
    hit_hand(player, hand)
    if hand.is_ace_split and player.has_max_hands
      hand.stand
    elsif hand.is_ace_split and not hand.has_aces
      hand.stand
    end
  end

  # This method takes care of paying players and taking their money.
  def settle_round
    @io.prep_round_results
    for player in @players
      for hand in player.hands
        if player.is_dealer
          @io.show_hands(player)
        else
          # This shouldn't happen unless we quit in the middle of a hand
          # or we're playing god.
          if @dealer.hand.total < 17 and not @play_god
            @dealer.hand.play(@shoe)
          end
  
          # Use total_high in case our hand is soft
          if (hand.total_high > @dealer.hand.total and \
            not hand.is_bust) or (@dealer.hand.is_bust and \
            not hand.is_bust)
            if hand.is_bj and not hand.is_even_money
              player.win_bet((hand.bet * BLACKJACK_PAYS) + \
                hand.bet)
              @dealer.pay(hand.bet * BLACKJACK_PAYS)
            else
              player.win_bet(hand.bet * 2)
              @dealer.pay(hand.bet)
            end
            @io.player_wins(player, hand)
          elsif hand.total_high == @dealer.hand.total
            if hand.is_bj and hand.is_even_money
              player.win_bet(hand.bet * 2)
              @dealer.pay(hand.bet)
              @io.player_wins(player, hand)
            else
              player.win_bet(hand.bet)
              @io.player_pushes(player, hand)
            end
          else
            @dealer.win_bet(hand.bet)
            @io.player_loses(player, hand)
          end
        end
      end
      player.finish_round
    end

    # Check to see if player is out of money, or doesn't have min_bet
    for player in @players
      unless player.is_dealer
        if player.bankroll == 0 or player.bankroll < @min_bet
          @io.player_out_of_money(player, @min_bet)
          @broke_players[@broke_players.length] = player
          @players.delete(player)
          throw :quit if @players.length == 1
        end
      end
    end
  end

  private :deal_round, :hit_hand, :hit_split_hand, :init_game, :place_your_bets
  private :play_round, :settle_round, :need_bet_change, :handle_insurance

end
