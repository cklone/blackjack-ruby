require 'Card'

# = Description
#
# This class represents a deck of 52 cards; jokers excluded.  It uses the 
# CardSuits and CardSymbols classes to build a deck of Card objects.
# Cards should not be taken from or put into this object; inherit from this
# class if you need to do that.
#
# = Synopsis
#
#   deck = Deck.new
#   deck.shuffle
#   deck.cut(34)
#   puts deck.to_s
#   for card in deck.cards
#     puts card.to_s
#   end
#
# = Author
#
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

class Deck
  # An array of Card objects.
  attr_reader :cards

  # This method uses CardSymbols and CardSuits to create an array of
  # Card objects which can be accessed through the cards attribute.
  def initialize
    @cards = []
    symbols = CardSymbols.new
    suits = CardSuits.new
    i = 0
    for suit in suits
      for symbol in symbols.keys
        @cards[i] = Card.new(symbol, suit)
        i += 1
      end
    end

    # Very important to do this to child classes
    # TODO: a regular deck = Deck.new returns the new object, but a child's
    # super returns the suits object above (perhaps because it's the first
    # object defined?).  I need to go figure out this behavior.
    # TODO: is it good practice to always include the line below to be safe?
    return self
  end

  # This method returns the whole deck as a string.  It includes an index
  # (1 - based) and Card ID with spaces in between each card; 
  # no line break at the end.
  def to_s
    # Default is to pad index to 2 chars, use 80 char line
    # Pad is 2 chars, card is 2 chars, colon is 1 and space is 1 = 6
    pad = 2
    cpl = (80 / (pad + 4)) # Cards per line

    # Check number of cards left; yes a deck only has 52 cards, but the
    # children are our future, so let's make this method work for them too.
    if cards.length > 99
      pad = 3
      cpl = (80 / (pad + 4))
    end

    result = String.new
    0.upto(@cards.length - 1) do |x|
      (pad - (x + 1).to_s.length).times { result += "0" }
      result += (x + 1).to_s
      result += ":"
      result += @cards[x].to_s
      result += " "
      result += "\n" if ( (x + 1) % cpl ) == 0 and x + 1 != @cards.length
    end
    return result
  end

  # Shuffles the deck.
  def shuffle
    @cards.replace @cards.sort_by { rand }
  end

  # Given a card number, cuts the deck.  Must be 1..{MAX_CARD - 1} to make
  # sure we get in between 2 cards.
  def cut(cut_at)
    if cut_at.is_a?(Integer) and cut_at > 0 and cut_at < @cards.length
      arr = @cards.slice!(cut_at, @cards.length - cut_at)
      @cards.replace(arr + @cards)
    else
      raise ArgumentError, "cut must be [1..#{@cards.length}]"
    end
  end

end
