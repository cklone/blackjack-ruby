#!/usr/bin/ruby -w
require 'test/unit'
require 'Shoe'

class TestShoe < Test::Unit::TestCase

  # Test shoe creation and card counts [1..8] decks.
  def test_shoe_creation
    1.upto(8) do |x|
      shoe = Shoe.new(x)
      assert_equal(52 * x, shoe.cards.length, "Shoe card counts [#{x}]")
      assert_not_nil(shoe, "Shoe created with #{x} decks.")
      assert_nothing_raised(ArgumentError) { Shoe.new(x) }
    end
  end

  # Test shoe creation with exceptions.
  def test_shoe_creation_with_exceptions
    assert_raise(ArgumentError) { Shoe.new("X") }
    assert_raise(ArgumentError) { Shoe.new(1000000000) }
    assert_raise(ArgumentError) { Shoe.new(-1) }
    assert_raise(ArgumentError) { Shoe.new(0) }
  end

  # Check a shuffled shoe.
  def test_shoe_shuffled
    shoe = Shoe.new(2)
    print "\nOriginal Shoe:\n#{shoe.to_s}\n"
    shoe.shuffle
    print "\nShuffled Shoe:\n#{shoe.to_s}\n"
  end

  # Check a cut shoe.
  def test_shoe_cut
    1.upto(3) do |x|
      num_decks = rand(8) + 1
      shoe = Shoe.new(num_decks)
      cut_at = rand(shoe.cards.length - 1) + 1
      x = shoe.cards[cut_at - 1]
      y = shoe.cards[cut_at]
      print "\n[#{x}] Pre-cut shoe:\n#{shoe.to_s}\n\n"
      shoe.cut(cut_at)
      print "\n[#{x}] Cut shoe [#{cut_at}] [#{x}|#{y}]:\n#{shoe.to_s}\n\n"
      assert_equal(52 * num_decks, shoe.cards.length, "Num Cards")
      assert_equal(shoe.cards[(shoe.cards.length - 1)], x, "Card Before")
      assert_equal(shoe.cards[0], y, "Card After")
    end
  end

  # Check for 52 unique cards in the shoe.
  def test_shoe_uniq_cards
    1.upto(8) do |x|
      shoe = Shoe.new(x)
      cards = shoe.cards.collect! { |card| card.to_s }
      cards.uniq!
      assert_equal(52, cards.length, "Unique cards for #{x} decks")
    end
  end

  # Check for deal exceptions.
  def test_shoe_deal_exceptions
    shoe = Shoe.new(1)

    # With 9 players, deal_hand will fail (6 cards * 9 players) = 54
    assert_raise(StandardError) { shoe.deal_hand(0,9) }

    # Deal all the cards from the shoe
    1.upto(52) { shoe.deal_card }
    assert_raise(StandardError) { shoe.deal_card }
  end

end
