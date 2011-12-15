require 'Hand'

# = Description
#
# This class represents the Dealer's hand.
#
# = Synopsis
#
#   dealers_hand = DealerHand.new
#   dealers_hand.hit_soft_17 = True # Default is False
#   dealers_hand.deal( [ Card1, Card2 ])
#   dealers_hand.play(shoe)
#   case dealers_hand.up_card.symbol
#   when "A"
#     puts "Insurance?"
#   when "6"
#     puts "If anyone hits when they could bust, I'm leaving this table"
#   ...
#
# = Author
#
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

class DealerHand < Hand
  # Set this attribute to True if dealer should hit a soft 17.
  attr_accessor :hit_soft_17

  # Initialize variables and call parent's initialize.
  def initialize
    @hit_soft_17 = nil
    super()
  end

  # This method stips the "NICE" on 21 for Dealer.  In fact, we should
  # replace it with "SUCKS".
  def to_s
    result = super
    result.slice!(" NICE")
    return result
  end

  # The dealer's first card is typically the up card.
  # Dealers will deal the first card down but flip it up with the second card.
  def up_card
    return @cards[0]
  end

  # Override the Hand.total method so that we always get back a single value
  # for the dealer.  This method also takes into account hit_soft_17
  # to determine the dealer's total.  *Note*: We do not want to just use
  # Hand.total_high because the dealer has special handling for soft 17s.
  def total
    tot = 0
    for card in @cards
      tot += card.value
    end
    if has_ace and tot < 12
      tot2 = tot + 10
      if tot2 > 17
        return tot2
      elsif tot2 == 17
        unless @hit_soft_17
          return tot2
        end
      end
    end
    return tot
  end

  # This method plays the dealer's hand based on the shoe that is passed in.
  # *Note*: Whether or not the table requires a dealer to hit a soft 17
  # is handled in the method total.
  def play(shoe)
    while can_hit and total < 17
      hit(shoe.deal_card)
    end
    stand
  end

end
