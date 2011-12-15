# = Description
#
# This class is a simple array that represents a card suit.  The suit is one
# character in length and the array is ordered from lowest to highest suit rank.
# * [0] D => Diamonds
# * [1] C => Clubs
# * [2] H => Hearts
# * [3] S => Spades
# 
# = Synopsis
#
#   suits = CardSuits.new
#   suits.each { |item|block| }
#   for suit in suits
#     puts suit
#   end
#
# = Author
#
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

class CardSuits < Array
  # This method creates an array of card suits.
  def initialize
    self[0] = "D"
    self[1] = "C"
    self[2] = "H"
    self[3] = "S"
  end
end
