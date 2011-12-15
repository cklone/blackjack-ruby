#!/usr/bin/ruby -w

# = Synopsis
#
# bj.rb: play a command-line version of BlackJack.  80-character screen is nice.
#
# = Usage
#
# bj [OPTIONS]
#
# -b, --bankroll [integer]:
#    set the player's starting bankroll
#
# -d, --debug:
#    debug mode; shows deck and dealer hands
#
# -g, --god:
#    play god mode; allows user to pick cards for each player's hand
# 
# -h, --help:
#    show help
# 
# = Author
#
# Author::    Christopher Kline (mailto:coder@cklone.com)
# Copyleft::  Copyleft 2007 Christopher Kline
# License::   Distributes under the same terms as Ruby

require 'getoptlong'
#require 'rdoc/usage'
require 'BlackJackGame'

def usage
  puts
  puts "bj [OPTIONS]"
  puts
  puts "  -b, --bankroll [integer]:"
  puts "    set the player's starting bankroll"
  puts
  puts "  -d, --debug:"
  puts "    debug mode; shows deck and dealer hands"
  puts
  puts "  -g, --god:"
  puts "    play god mode; allows user to pick cards for each player's hand"
  puts
  puts "  -h, --help:"
  puts "    show help"
  puts
end

opts = GetoptLong.new(
  [ "--bankroll",   "-b", GetoptLong::REQUIRED_ARGUMENT],
  [ "--debug",      "-d", GetoptLong::NO_ARGUMENT ],
  [ "--god",        "-g", GetoptLong::NO_ARGUMENT ],
  [ "--help",       "-h", GetoptLong::NO_ARGUMENT ]
)

debug = nil
god = nil
bankroll = 1000

opts.each do |opt, arg|
  case opt
  when '--bankroll'
    if arg.to_i == 0
      puts "Bad bankroll value #{arg}, using #{bankroll}."
    else
      bankroll = arg
    end
  when '--debug'
    debug = 1
  when '--god'
    god = 1
  when '--help'
    # Normally, I would use the line below, but it broke on my web host
    # system due to a problem with the rdoc installation.  I didn't
    # want to chance the game not running on first go...
    #
    # RDoc::usage
    
    usage
    exit
  end
end

game = BlackJackGame.new
game.bankroll = bankroll.to_i
game.debug = debug
game.play_god = god
game.play
