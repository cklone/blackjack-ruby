require 'Card'

# = Description
# This class represents a single hand of BlackJack.
#
# = Synopsis
#   
#   hand = Hand.new
#   hand.bet = 10
#   hand.deal([ Card1, Card2 ])
#   puts "BLACKJACK!" if hand.is_bj
#   if hand.can_hit
#     hand.hit(newcard)
#     puts hand.to_s
#   end
#   hand.stand
#
# = Author
# 
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

class Hand
  # Attribute to set the amount of the bet.
  attr_accessor :bet, :insurance_bet
  # Attribute to set an even_money flag.
  attr_accessor :is_even_money

  # Attribute gives info about splits.
  attr_accessor :is_split, :is_ace_split

  # Attribute to read cards from hand, use deal and hit to add cards to hand.
  attr_reader :cards

  # This method initializes variables.
  def initialize
    @bet = 0.00
    @insurance_bet = 0.00
    @is_even_money = nil
    @stand = nil
    @is_split = nil
    @is_ace_split = nil
    @cards = []

    return self
  end

  # This method return a string that represents the hand in the form:
  # [Card1|Card2|...]: <Total> <Special Text>; where <Total> can be
  # an "or" statement and <Special Text> can be "BUSTED", "BLACKJACK", etc.
  def to_s
    result = "[#{@cards.join("|")}]: "
    if is_soft
      result += total.join(" or ")
    else
      result += total.to_s
    end
    if is_bust
      result += " BUSTED"
    elsif is_bj
      result += " BLACKJACK"
    elsif total_high == 21
      result += " NICE"
    end
    return result
  end

  # True only if hand is bust.
  def is_bust
    unless total.is_a?(Array)
      return 1 if total > 21
    end
    return nil
  end

  # True if a player can hit on the hand.
  def can_hit
    if total.is_a?(Array)
      return 1
    else
      return 1 if total < 21
    end
    return nil
  end

  # This method adds multiple cards to the hand (usually when dealing).
  def deal(cards)
    @cards = cards
  end

  # This method adds a card to the hand.
  def hit(card)
    @cards[@cards.length] = card
  end

  # This method is used to split a hand.  It sets the is_split attribute
  # (important for determining BlackJack hands) and returns the new hand.
  def split
    @is_split = 1
    @is_ace_split = 1 if has_aces
    hand = Hand.new
    hand.is_split = 1
    hand.is_ace_split = 1 if has_aces
    hand.hit(@cards.slice!(1))
    return hand
  end

  # This method returns a total for the hand.  *IMPORTANT*: This
  # method will return a single integer _or_ an integer array.  It will
  # return an array of length 2 if the hand is soft (e.g. 7 or 17 for an Ace
  # and a 6).  The caller of this method should use the is_soft method to
  # test whether the result will be an Array or not.  If the hand is soft,
  # but the attribute stand is True, then the higher value is returned.
  def total
    tot = 0
    for card in @cards
      tot += card.value
    end
    if has_ace and tot < 12
      tot2 = tot + 10
      if @stand
        return tot2
      else
        return [ tot, tot2 ]
      end
    else
      return tot
    end
  end

  # This method always returns a single integer for the total of the hand.
  # In the case of a soft hand, it will return the higher total.
  def total_high
    if is_soft
      return total[1]
    end
    return total
  end

  # Returns True if the hand is soft (i.e. contains an Ace and is < 12).
  def is_soft
    if total.is_a?(Array)
      return 1
    end
    return nil
  end

  # Returns True if the hand is a BlackJack.  Split hands cannot be BlackJack.
  def is_bj
    if @cards.length == 2 and has_ace and not is_split and \
      ( @cards[0].value == 10 or @cards[1].value == 10 )
      return 1
    end
    return nil
  end

  # Returns True if the hand can be split.
  def can_split
    if @cards.length == 2
      if @cards[0].symbol == @cards[1].symbol
        return 1
      end
    end
    return nil
  end

  # Returns True if the hand contains an Ace.
  def has_ace
    for card in @cards
      return 1 if card.is_ace
    end
    return nil
  end

  # Returns True if the hand is a pair of aces.
  def has_aces
    if @cards.length == 2 and @cards[0].is_ace and @cards[1].is_ace
      return 1
    end
    return nil
  end
  
  # Returns True if hand is finished (hand.stand has been called).
  def is_done
    return @stand
  end

  # Call this method when you want to stand.
  def stand
    @stand = 1
  end

end
