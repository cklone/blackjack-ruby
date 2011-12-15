require 'CardSuits'
require 'CardSymbols'

# = Description
#
# This class represents a single card and consists of 3 elements:
# symbol, suit and value.
# The symbol is one character: 2..9, [T]en, [A]ce, [J]ack, etc.
# The suit is one character: [S]pade, [H]eart, [C]lub or [D]iamond.
# *Note*: The value of an [A]ce is set at 1.
# It is up to the caller to handle other cases like "soft" BlackJack hands.
#
# = Synopsis
#
#   card = Card.new(symbol, suit)
#   puts card.to_s
#   if card.is_ace
#     puts card.to_s_with_value
#   end
#   if card.is_valid
#     ...
#
# = Author
#
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

class Card
  # Attribute is_valid set upon object creation.
  attr_reader :is_valid
  attr_reader :symbol, :suit, :value

  # Create class variables for card symbols and suits.
  @@symbols = CardSymbols.new
  @@suits = CardSuits.new

  # This method creates the card and sets the is_valid attribute.
  def initialize(symbol, suit)
    if @@symbols.key?(symbol) and @@suits.include?(suit)
      @is_valid = 1
      @symbol = symbol
      @suit = suit
      @value = @@symbols[symbol]
    else
      @is_valid = nil
    end
  end

  # This method returns a 2 character string for the card.
  def to_s
    return "#@symbol#@suit"
  end

  # This method returns a 5 character string for the card:value.
  # Value is padded to 2 characters.
  def to_s_with_value
    value = String.new
    (2 - @value.to_s.length).times { value += "0" }
    value += @value.to_s
    return "#@symbol#@suit:#{value}"
  end

  # This method returns TRUE only if the card is an Ace.
  def is_ace
    if @symbol == "A"
      return 1
    end
    return nil
  end

end
