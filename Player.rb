require 'Hand'

# = Description
#
# This class represnts a BlackJack player, complete with their name,
# bankroll, bet increment and hand.
#
# = Synopsis
#
#   player = Player.new("Bob", 1000)
#   player.bet = 100 # High roller
#   puts "#{player.name}, you have #{player.bankroll} bucks."
#   if hand.has_aces
#     player.split_hand(hand) # or do you like to lose money?
#   ...
#
# = Author
#
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

class Player
  # This defines the maximum number of hands a player can have or split.
  MAX_HANDS = 4

  attr_accessor :name, :bankroll, :bet, :hands
  attr_reader :num_hands

  # Initialize the total bankroll for all players.
  @@bankroll = 0
  @@total_hands = 0

  def initialize(name, bankroll)
    @name = name
    @bankroll = bankroll
    @bet = 0
    @num_hands = 0
    @hands = []
    @@bankroll += bankroll
  end

  # This method returns a string in the form: Name [Bet] [Bankroll].
  def to_s
    result = @name
    if self.has_a_hand and not self.is_dealer
      result += " [\$#{@bet.to_s}]"
    end
    result += " [\$#{@bankroll.to_s}]"
    return result
  end

  # This method returns a string in the form: Name [Bankroll].
  def bankroll_to_s
    return "#@name [\$#{@bankroll.to_s}]"
  end

  # This method returns a summary for the player in the form:
  # Name [Hands Played] [Bankroll]
  def summary
    return "#@name [#@num_hands hand(s)] [\$#{@bankroll.to_s}]"
  end

  # This method returns a string for the hand in the form:
  # Name [HandIndex] [HandBet] [Bankroll].
  def hand_to_s(hand)
    result = @name
    i = @hands.index(hand)
    if i and @hands.length > 1 and not self.is_dealer
      result += " [Hand #{i + 1}] [\$#{hand.bet.to_s}]"
    elsif self.has_a_hand and not self.is_dealer
      result += " [\$#{@bet.to_s}]"
    end
    result += " [\$#{@bankroll.to_s}]"
    return result
  end

  # This method returns the total of everyone's bankroll
  def all_bankrolls
    return @@bankroll
  end

  # This method places a bet for the player.  It instatiates the player's hand
  # and deducts the bet from the player's bankroll.  It returns the hand.
  def start_hand
    @num_hands += 1
    @@total_hands += 1
    i = @hands.length
    @hands[i] = Hand.new
    self.place_bet(@hands[i])
    return @hands[i]
  end

  # This method places the player's bet on the hand.
  def place_bet(hand)
    hand.bet = @bet
    @bankroll -= @bet
    @@bankroll -= @bet
  end

  # This method places an insurance bet on the hand.
  def place_insurance_bet(hand, insurance_bet)
    hand.insurance_bet = insurance_bet
    @bankroll -= insurance_bet
    @@bankroll -= insurance_bet
  end

  # This method is called when the player wins the insurance bet.
  def win_insurance_bet(hand, winnings)
    @bankroll += winnings
    @@bankroll += winnings
    #hand.insurance_bet = 0
  end

  def lose_insurance_bet(hand)
    #hand.insurance_bet = 0
  end

  # This method destroys a player's hand.
  def finish_round
    @hands = []
  end

  # This method returns True if the player has at least one hand
  def has_a_hand
    return 1 if @hands.length > 0
    return nil
  end

  # This method returns True if the player has the maximum number of hands.
  def has_max_hands
    return 1 if @hands.length == MAX_HANDS
    return nil
  end

  # This method takes care of doubling the player's bet.
  def double_bet(hand)
    hand.bet += @bet
    @bankroll -= @bet
    @@bankroll -= @bet
  end

  # This method adds the winnings to the player's bankroll.
  def win_bet(winnings)
    @bankroll += winnings
    @@bankroll += winnings
  end

  # Returns True if the Player is the Dealer.
  def is_dealer
    if self.is_a?(Dealer)
      return 1
    end
    return nil
  end

  # This method should be used when the player splits their hand.  Send in the
  # hand that should be split and this method will create and return the
  # new hand.
  def split_hand(hand)
    if self.can_split_hand(hand)
      @num_hands += 1
      @@total_hands += 1
      i = @hands.length
      @hands[i] = hand.split
      self.place_bet(@hands[i])
      return @hands[i]
    else
      raise ArgumentError, "Hand cannot be split: #{hand.to_s}"
    end
  end

  # This method returns true if the hand can be split and the player has not
  # exceeded the maximum number of hands.
  def can_split_hand(hand)
    if hand.can_split and not self.has_max_hands
      return 1
    end
    return nil
  end

  # This method should be used to determine if the player can double their bet.
  # Used for splits, double down or any other purpose.
  def can_double_bet
    return 1 unless @bankroll < @bet
    return nil
  end

  # This method should be used to determine if the player can put up
  # half their bet for insurance.
  def can_afford_insurance
    return 1 if (@bet / 2) <= @bankroll
    return nil
  end

  # This method returns True if the Player has multiple hands, nil otherwise.
  def has_multiple_hands
    return 1 if @hands.length > 1
    return nil
  end

  # Returns the total number of hands dealt.
  def total_hands
    return @@total_hands
  end

end
