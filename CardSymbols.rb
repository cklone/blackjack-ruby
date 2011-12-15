# = Description
#
# This class is a simple hash where key=symbol and value=card value.
# The symbol is kept to one character, so 10 is "T".
# *Note*: The value of an [A]ce is set at 1.
# It is up to the caller to handle other cases like "soft" BlackJack hands.
# * 2..9 => 2..9
# * T    => Ten
# * J    => Jack
# * Q    => Queen
# * K    => King
# * A    => Ace
# TODO: Although not needed for BlackJack, this class might need a
# ranking element so that we know a Queen is higher than a Jack.
#
# = Synopsis
#
#   symbols = CardSymbols.new
#   symbols.each { |key, value| block }
#   for symbol in symbols.keys
#     puts symbol
#   end
#
# = Author
#
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

class CardSymbols < Hash
  # This method creates a hash of symbols and values; ace is 1.
  def initialize
    self["A"] = 1
    2.upto(9) do |x|
      self[x.to_s] = x
    end
    self["T"] = 10
    self["J"] = 10
    self["Q"] = 10
    self["K"] = 10
  end
end
