require 'Player'

# = Description
#
# This class represents a special type of player:  The *Dealer*.
#
# = Synopsis
#
#   dealer = Dealer.new
#   puts dealer.to_s
#   dealer.pay(1000000)
#
# = Author
#
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

class Dealer < Player
  # An english name for the Dealer.
  DEALERS_NAME = "Dealer"
  DEALERS_BANKROLL = 0

  # Set this attibute to True if the dealer should hit a soft 17.
  attr_accessor :hit_soft_17

  def initialize
    @hit_soft_17 = nil
    super(DEALERS_NAME, DEALERS_BANKROLL)
  end

  # This method shows the Dealer's name and the bankroll.  The dealer is the
  # only player that can have a negative bankroll.
  def to_s
    if @bankroll < 0
      bankroll = "-$#{@bankroll.abs.to_s}"
    else
      bankroll = "$#{@bankroll.to_s}"
    end
    return "#{@name} [#{bankroll}]"
  end

  # This method just calls to_s.
  def summary
    self.to_s
  end
  
  # This method should be called when the house loses.
  def pay(amount)
    @bankroll -= amount
    @@bankroll -= amount
  end

  # This method overrides Player.start_hand because we don't want to place
  # a bet and we also want to create a DealerHand.
  def start_hand
    @hands[0] = DealerHand.new
    @hands[0].hit_soft_17 = @hit_soft_17
    return @hands[0]
  end

  # A dealer can never split a hand
  def can_split_hand(hand)
    return nil
  end

  # Since the dealer only ever has one hand, we'll return hands[0] for hand.
  def hand
    return @hands[0] if self.has_a_hand
    return nil
  end

end
