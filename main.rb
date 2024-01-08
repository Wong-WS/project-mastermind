module Common
  RANGE = ["1","2","3","4","5","6"]

  def valid_input?(input)
    input.match?(/\A[1-6]{4}\z/)
  end

  def player_input
    puts "Enter your code: four numbers (1 - 6) in a row on one line"
    input = gets.chomp
    until valid_input?(input)
      puts "Make sure you have entered a valid code!"
      input = gets.chomp
    end
    @player_input_code = input.split("").map(&:to_i)
  end
end

class PlayerBreaker
  include Common
  attr_accessor :player_input_code

  def initialize
    @player_input_code = []
  end
end

class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end
end

class Board
  attr_accessor :secret_code

  def initialize
    @secret_code = []
    @winner = false
    @player_breaker = PlayerBreaker.new

    puts "Enter 1 to be the code breaker or 2 to be the code maker."
    @player_choice = gets.chomp
    @turn_count = 1
  end

  def decide_play_method
    case @player_choice
    when "1"
      play_player_breaker
    else
      play_player_maker
    end
  end

  def play_player_breaker
    generate_code
    until @turn_count >= 13
      puts "Turn: #{@turn_count}"
      @player_breaker.player_input
      check_win(@player_breaker.player_input_code)
      check_code(@player_breaker.player_input_code, @secret_code)
      @turn_count += 1
    end
    result
  end


  def generate_code
    @secret_code = Array.new(4) { rand(1..6) }
  end

  def check_code(player_input_code, secret_code)

    matching_digits = player_input_code.zip(secret_code).select { |a, b| a == b}.map(&:first)

    if matching_digits.empty?
      puts "Match: 0"
    else
      puts "Match: #{matching_digits.length}"
    end

    partial_digits = player_input_code.select { |number| secret_code.include?(number) }

    partial_digits -= matching_digits

    if partial_digits.empty?
      puts "Partial: 0"
    else
      puts "Partial: #{partial_digits.length}"
    end
  end

  def check_win(player_input_code)
    if player_input_code == @secret_code
      @turn_count = 13
      @winner = true
    end
  end

  def result
    if @winner == true
      puts "Congratulations, you solved it!"
    else
      puts "The code was #{@secret_code}. Better luck next time!"
    end
  end
end

puts "\r\n"
puts 'Welcome to Mastermind: a code breaking game between you and the computer.'
puts 'You can choose to be either the code maker, or code breaker.'
puts 'The code maker creates a 4 digit code using numbers from 1 to 6. Duplicates are allowed.'
puts 'The code breaker has to guess the exact code in under 12 turns, receiving hints each turn.'
puts 'Hints: "match" = correct value and position; "partial" = correct value, incorrect position.'
puts 'Can you beat the machine? Good luck!'
puts "\r\n"

game = Game.new
game.board.decide_play_method
