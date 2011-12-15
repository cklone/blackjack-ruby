require 'Deck'

# = Description
#
# This class represents the dealer's shoe, which can be 1 or multiple
# card decks.  The cards in the shoe are dealt using deal_card and
# deal_hand which causes the card pile to shrink.  The caller should use the
# can_play method to make sure there is enough cards to deal.
#
# = Synopsis
#
#   shoe = Shoe.new(6) # Shoe of 6 decks
#   shoe.shuffle
#   shoe.cut_at(123)
#   puts shoe.to_s
#   while shoe.can_play
#     puts shoe.deal_card
#   ...
#
# = Author
#
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

class Shoe < Deck
  # Average hand size is used along with the number of players
  # to determine if the deck contains enough cards to play another round.
  AVERAGE_HAND_SIZE = 6
  
  # This constant is used for the maximum number of decks that can be used.
  # This number is based on the typical maximum decks at casinos.
  MAX_DECKS = 8

  # Of course, we have to have at least one deck in the show.
  MIN_DECKS = 1

  attr_reader :num_decks, :cards

  # This method is used to create the shoe and requires the number of decks
  # as an argument.  The default number of decks is 1, so if the argument is
  # invalid, this method will still instantiate a deck object with 1 deck.
  def initialize(num_decks)
    @num_decks = num_decks
    @cards = []

    # Validate num_decks; raise exceptions
    if not num_decks.is_a?(Integer) \
      or num_decks < MIN_DECKS or \
      num_decks > MAX_DECKS
      raise ArgumentError, "num_decks must be [#{MIN_DECKS}..#{MAX_DECKS}]"
    end

    # Create the shoe
    i = 0
    1.upto(num_decks) do |x|
      @cards += super().cards # () in super is important due to arg diffs
    end
  end

  # This method overrides Deck.to_s to add the number of decks
  def to_s
    return "[#@num_decks deck shoe]\n" + super
  end

  # This method return True only if the shoe contains enough cards to deal
  # another round.  The number of players (including the dealer) is passed in
  # and the constant AVERAGE_HAND_SIZE is used.
  def can_play(player_cnt)
    if @cards.length >= player_cnt * AVERAGE_HAND_SIZE
      return 1
    end
    return nil
  end

  # Deals a card out of the deck.
  def deal_card
    if @cards.length > 0 then
      return @cards.slice!(0)
    else
      raise StandardError, "No cards left in shoe; please use can_play"
    end
  end

  # This method deals 2 cards as an initial hand given the number of players.
  # It takes into account the way BlackJack is dealt, one card at a time
  # for each player.
  def deal_hand(player_index, player_cnt)
    if can_play(player_cnt - player_index) then
      return [ @cards.slice!(0), @cards.slice!(player_cnt - player_index - 1) ]
    else
      raise StandardError, "Not enough cards left in shoe; please use can_play"
    end
  end

end
