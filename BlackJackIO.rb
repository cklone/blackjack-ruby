require 'BlackJackGame'
require 'Shoe'
require 'Player'
require 'Dealer'
require 'Hand'
require 'DealerHand'

# = Description
#
# This class represents the I/O for the game.  This class can be replaced
# with another class to make the game a GUI instead of command-line.
# A terminal at least 80 characters wide is recommended.
# 
# = Synopsis
# 
#   io = BlackJackIO.new
#   io.welcome_msg
#   io.get_player_cnt
#   ...
#   io.show_game_results
#   io.quit
#
# = Author
#
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

class BlackJackIO
  # Since we're dealing with a cmd-line interface, let's limit the name.
  MAX_PLAYER_NAME_LENGTH = 10

  # This method initializes variables.
  def initialize
    @player_cnt = 0
  end

  # This method displays a welcome message.
  def welcome_msg
    puts
    puts "Welcome to BlackJack!"
    puts "Press i at any time for instructions."
    puts "Press q at any time to quit."
    puts
  end

  # This method displays instructions.
  def instructions
    puts
    puts "Press i at any time for instructions."
    puts "Press q at any time to quit."
    puts "Press Enter to accept default answers."
    puts "  The default usually appears in brackets [] at the end."
    puts "Press the letter in brackets for the action:"
    puts "  [H]it     => press h"
    puts "  S[T]and   => press t"
    puts "  [D]ouble  => press d"
    puts "  S[P]lit   => press p"
    puts "Inputs are CaSe INsensitive"
    puts
    puts "Your hand will be presented in the form:"
    puts "  [Dealer's UpCard] / [Card1|Card2]: Total"
    puts "  Name [CurrentBet] [Bankroll]"
    puts
  end

  # This method gets the number of decks from the player.
  def get_num_decks
    result = nil
    while not result
      print "Enter number of decks [#{Shoe::MIN_DECKS}.."
      print "#{Shoe::MAX_DECKS}] [1]: "
      result = gets
      result = result.strip
      if result.to_i >= Shoe::MIN_DECKS and result.to_i <= Shoe::MAX_DECKS
        return result.to_i
      elsif result.downcase == "q"
        throw :quit
      elsif result.downcase == "i"
        result = nil
        instructions
      elsif result == ""
        return Shoe::MIN_DECKS
      else
        result = nil
        try_again
      end
    end
  end

  # This method gets the number of players from the user.
  def get_player_cnt(max_players)
    @player_cnt = 0
    while @player_cnt < 1 or @player_cnt > max_players
      print "How many players [1-#{max_players}] [1]? "
      @player_cnt = gets
      @player_cnt = @player_cnt.strip

      if @player_cnt.to_i > 0 and @player_cnt.to_i <= max_players
        @player_cnt = @player_cnt.to_i
      elsif @player_cnt.downcase == "q"
        throw :quit
      elsif @player_cnt.downcase == "i"
        @player_cnt = 0
        instructions
      elsif @player_cnt == ""
        @player_cnt = 1
      else
        @player_cnt = 0
        try_again
      end
    end
    return @player_cnt
  end

  # This method allows the user to cut the shoe.
  def cut_shoe(shoe, player)
    result = nil
    while not result
      print "#{player.name}, please cut the shoe [1.."
      print "#{ (shoe.cards.length - 1).to_s }] [random]: "
      result = gets
      result = result.strip
      if result.to_i > 0 and result.to_i < shoe.cards.length
        return result.to_i
      elsif result == ""
        result = rand(shoe.cards.length - 1) + 1
        puts "Will cut the deck at #{result}"
        return result
      elsif result.downcase == "q"
        throw :quit
      elsif result.downcase == "i"
        result = nil
        instructions
      else
        result = nil
        try_again
      end
    end
  end

  # This method gets the name of each player from the user; Default is
  # "Player X" if nothing is entered.
  def get_players_names
    players_names = []
    0.upto(@player_cnt - 1) do |x|
      name = nil
      while name == nil
        print "What's you name, [Player #{(x + 1).to_s}]? "
        name = gets
        name = name.strip

        # Check for names that are too long
        if name.length > MAX_PLAYER_NAME_LENGTH
          name = name.slice(0..(MAX_PLAYER_NAME_LENGTH - 1))
        end

        if name == ""
          name = "Player " + (x + 1).to_s
        elsif name.downcase == "q"
          throw :quit
        elsif name.downcase == "i"
          name = nil
          instructions
        elsif players_names.include?(name) or name == Dealer::DEALERS_NAME
          # Check for the existence of the same name
          name = nil
          try_again
        end
      end
      players_names[x] = name
    end
    return players_names
  end

  # This method notifies the user that they need to change their bet.
  def need_to_change_bet(player)
    puts "#{player.name}, you need to change your bet size."
  end

  # This method gets the bet size from each player.  It then sets the bet
  # size on the player object.
  def get_players_bet_sizes(players, min_bet, max_bet, bet_increment)
    for player in players
      next if player.is_dealer
      done = 0
      while done != 1
        max_bet = player.bankroll if player.bankroll < max_bet
        default_bet = min_bet
        default_bet = player.bet if player.bet != 0
        default_bet = player.bankroll if player.bankroll < default_bet
        print "#{player.name}, choose a bet size [\$#{min_bet.to_s}.."
        print "\$#{max_bet.to_s}] in \$#{bet_increment.to_s} "
        print "increments [\$#{default_bet.to_s}]: "
        bet = gets
        bet = bet.strip
        if bet.to_i > 0 and bet.to_i <= max_bet and \
          bet.to_i % bet_increment == 0
          player.bet = bet.to_i
          done = 1
        elsif bet == ""
          player.bet = default_bet
          done = 1
        elsif bet.downcase == "q"
          throw :quit
        elsif bet.downcase == "i"
          instructions
        else
          try_again
        end
      end
    end
  end

  # This method displays all or part of the shoe.
  def show_shoe(shoe)
    print "#{shoe.to_s}\n\n"
  end

  # This method displays hands for all of the players passed in.
  # You can pass in a single player or a list of players.
  def show_hands(players)
    if players.is_a?(Array)
      for player in players
        for hand in player.hands
          puts "#{player.hand_to_s(hand)}: #{hand.to_s}"
        end
      end
    else
      player = players
      for hand in player.hands
        puts "#{player.hand_to_s(hand)}: #{hand.to_s}"
      end
    end
  end

  # This method display the player's hand that is passed in.
  def show_hand(player, hand)
    puts "#{player.hand_to_s(hand)}: #{hand.to_s}"
  end

  # This method asks the player if they want change their bet.
  def change_bet_sizes
    result = nil
    while not result
      print "Place your bets.  Change bets [y|n] [n]? "
      result = gets
      result = result.strip.downcase
      case result
      when "y"
        return 1
      when "n", ""
        return nil
      when "q"
        throw :quit
      when "i"
        instructions
      end
      result = nil
      try_again
    end
  end

  # This method shows the dealer's up card.
  def show_dealers_up_card(dealer)
    puts "Dealer's up card is [#{dealer.hand.up_card}]"
  end

  # This method takes care of asking the player if they want
  # insurance or even money.  If a dealer is showing an ace and the
  # player has a BlackJack, they can request even money where they
  # just win their regular bet regardless of whether the dealer
  # has BlackJack.  Insurance and even money are considered mutually
  # exclusive.
  def player_want_insurance(player, even_money_offered)
    result = nil
    while not result
      # Insurance is only offered at first deal, so we access the
      # player's first hand only.
      if player.hands[0].is_bj and even_money_offered
        print "#{player.name}, Would you like even money [y|n]? "
      elsif
        print "#{player.name}, Would you like insurance [y|n]? "
      end

      result = gets
      result = result.strip.downcase
      case result
      when "y"
        if player.hands[0].is_bj and even_money_offered
          return "e"
        else
          return result
        end
      when "n"
        return result
      when "q"
        throw :quit
      when "i"
        instructions
      end
      result = nil
      try_again
    end
  end

  # This method asks the player if they want to play again.
  def want_to_play(shoe)
    result = nil
    while not result
      print "\nShoe #{shoe} finished.  Want to play another shoe [y|n]? "
      result = gets
      result = result.strip.downcase
      case result
      when "y"
        return 1
      when "n", "q"
        throw :quit
      when "i"
        instructions
      end
      result = nil
      try_again
    end
  end

  # This method gets the players move, forgiving case.  Letter "S" is not
  # used to avoid confusion between Stand and Split.
  # * [H]it
  # * [D]ouble
  # * S[T]and
  # * S[P]lit
  # * [Q]uit
  # * [I]nformation
  def get_players_move(dealer, player, hand)
    result = nil
    dumb = nil
    while not result
      if player.is_dealer then
        # This only happens if we're playing god
        options = "[H]it, S[T]and or let [G]od.super decide? "
      else
        options = "[H]it"
        if player.can_split_hand(hand) and player.can_double_bet
          options += ", S[T]and, [D]ouble or S[P]lit? "
        elsif player.can_double_bet
          options += ", S[T]and or [D]ouble? "
        else
          options += " or S[T]and? "
        end
      end

      print "Dealer's up card / #{player.name}'s hand: ["
      print "#{dealer.hand.up_card.to_s}] / #{hand.to_s}\n"
      print "#{player.hand_to_s(hand)}: #{options}"
      result = gets
      result = result.strip.downcase
      case result
      when "h"
        if hand.is_bj or (not hand.is_soft and hand.total >= 17)
          if not dumb
            puts "#{player.name}, I suggest you stand."
            dumb = 1
            result = nil
          else
            puts "#{player.name}, I guess you too like to live dangerously."
            return result
          end
        else
          return result
        end
      when "t"
        return result
      when "d"
        return result if player.can_double_bet and not player.is_dealer
      when "p"
        return result if player.can_split_hand(hand) and player.can_double_bet
      when "g"
        return result if player.is_dealer
      when "q"
        throw :quit
      when "i"
        instructions
      end
      result = nil
      try_again
    end
  end

  # This method allows the user to set the hand for each player.
  # Press enter to just get the next card in the shoe.  *Note*: This will mess
  # up the order in which the cards are usually dealt because we are asking
  # for 2 cards at once for 1 player; the cards are dealt 1 card at a time.
  # Also, the card you enter will just "appear", it doesn't get taken from
  # the shoe.
  def set_hand(shoe, player)
    cards = []
    0.upto(1) do |x|
      cards[x] = set_card(shoe, player, x + 1)
    end
    return cards if cards.length == 2
    return nil
  end

  # This method takes card of asking for a single card and validating
  # that card.
  def set_card(shoe, player, card_num)
    card = nil
    while not card
      print "God, enter card "
      print "#{card_num.to_s} " if card_num
      print "for #{player.name} [#{shoe.cards[0].to_s}]: "
      card = gets
      card = card.strip.upcase
      if card.length == 2
        symbol = card.slice!(0, 1)
        suit = card.slice!(0, 1)
        card = Card.new(symbol, suit)
        if not card.is_valid
          card = nil
          try_again
        end
      elsif card == ""
        card = shoe.deal_card
      elsif card.downcase == "q"
        throw :quit
      else
        card = nil
        try_again
      end
    end
    return card
  end

  # This method shows a "Try Again" message.
  def try_again
    puts "Sorry!  Try again."
  end

  # This method starts a new round.
  def start_round(players, num_shoes, num_rounds)
    print "\nShoe #{num_shoes}, Round #{num_rounds},"
    print " #{players.length - 1} Player(s)\n"
    79.times { print "-" }
    puts
  end

  # This method show the results of the game.
  def show_game_results(players, num_rounds, num_shoes)
    puts; 79.times { print "-" }; puts
    for player in players
      puts player.summary
    end
    puts "Total of all bankrolls: \$#{players[0].all_bankrolls}"
    puts "Total rounds completed: #{num_rounds}"
    puts "Total shoes completed: #{num_shoes}"
  end

  # This method prepares for showing the results of the round.
  def prep_round_results
    puts; 79.times { print "=" }; puts
  end

  # This method is called when the player wins.
  def player_wins(player, hand)
    puts "#{player.bankroll_to_s} #{hand.to_s}: You WIN ;-)"
  end

  # This method is called when the player pushes.
  def player_pushes(player, hand)
    puts "#{player.bankroll_to_s} #{hand.to_s}: You PUSH :-|"
  end

  # This method is called when the player loses.
  def player_loses(player, hand)
    puts "#{player.bankroll_to_s} #{hand.to_s}: You LOSE :-("
  end

  # This method is called when the player places an insurance bet.
  def player_places_insurance_bet(player, hand)
    print "#{player.name}, Insurance bet placed [\$#{hand.insurance_bet.to_s}]"
    print " [\$#{player.bankroll.to_s}]\n"
  end

  # This method is called when the player wins the insurance bet.
  def player_wins_insurance(player)
    puts "#{player.name}, you won the insurance bet :-|"
  end

  # This method is called when the player loses the insurance bet.
  def player_loses_insurance(player)
    puts "#{player.name}, you lose the insurance bet :-("
  end

  # This method is called when the player is out of money.
  def player_out_of_money(player, min_bet)
    puts
    if player.bankroll == 0
      puts "Sorry #{player.name}, you're out of money."
    else
      puts "Sorry #{player.name}, you need \$#{min_bet} to play."
      puts player.bankroll_to_s
    end
    puts "There is an ATM just beyond those Top Dollar slot machines."
    puts "Good luck."
    puts
  end

  # This method shows a message when the game is over.
  def quit
    print "\nThank you for playing BlackJack!\n"
  end

end
