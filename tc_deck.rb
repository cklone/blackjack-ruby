#!/usr/bin/ruby -w
require 'Deck'
require 'test/unit'

# = Description
#
# This class is used to test the Deck class.
#
# = Author
#
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

class TestDeck < Test::Unit::TestCase

  # Create a deck for all of the tests.
  def setup
    @deck = Deck.new
    @cards = @deck.cards
  end

  # Check the original deck.
  def test_deck_card_counts
    print "\nOriginal Deck:\n#{@deck.to_s}\n"
    assert_equal(52, @cards.length, "Num Cards")
  end
  
  # Check for all unique cards.
  def test_deck_cards_uniq
    arr = @deck.cards.uniq
    assert_equal(52, arr.length, "Num unique cards")
  end

  # Check the shuffled deck 3 times.
  def test_deck_shuffle
    1.upto(3) do |x|
      @deck.shuffle
      print "\nShuffled Deck [#{x}]:\n#{@deck.to_s}\n"
      assert_equal(52, @cards.length, "Num Cards")
    end
  end

  # Check the cut deck 3 times with random cut points.
  def test_deck_cut
    1.upto(3) do |x|
      cut_at = rand(51) + 1
      x = @cards[cut_at - 1]
      y = @cards[cut_at]
      @deck.cut(cut_at)
      print "\nCut Deck at #{cut_at} [#{x}|#{y}]:\n#{@deck.to_s}\n\n"
      assert_equal(52, @cards.length, "Num Cards")
      assert_equal(@cards[(@cards.length - 1)], x, "Card Before")
      assert_equal(@cards[0], y, "Card After")
    end
  end

end
