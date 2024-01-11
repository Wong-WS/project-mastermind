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

class PlayerMaker
  include Common
  attr_accessor :player_input_code, :comp_input_code

  def initialize
    @player_input_code = []
    @comp_input_code = []
  end

  def first_guess
    @comp_input_code = generate_random_code
    puts "Computer guessed: #{@comp_input_code}"
  end

  def solve
    new_guess = generate_new_guess(@player_input_code, find_matching_indices(@player_input_code, @comp_input_code))
    @comp_input_code = new_guess
    puts "Computer guessed: #{@comp_input_code}"
  end

  private

  def generate_random_code
    Array.new(4) { rand(1..6) }
  end

  def find_matching_indices(code1, code2)
    code1.each_index.select { |i| code1[i] == code2[i] }
  end

  def generate_new_guess(previous_guess, matches)
    new_guess = previous_guess.map.with_index do |digit, index|
      matches.include?(index) ? digit : rand(1..6)
    end
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
    @player_maker = PlayerMaker.new

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
      puts "\r\n"
    end
    result
  end

  def play_player_maker
    @player_maker.player_input
    @player_maker.first_guess
    check_code(@player_maker.player_input_code, @player_maker.comp_input_code)
    @turn_count += 1
    until @turn_count >= 13
      puts "Turn: #{@turn_count}"
      @player_maker.solve
      check_win_comp
      check_code(@player_maker.player_input_code, @player_maker.comp_input_code)
      @turn_count += 1
      puts "\r\n"
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

  def check_code_comp(player_input_code, comp_input_code)

    matching_digits = player_input_code.zip(comp_input_code).select { |a, b| a == b}.map(&:first)

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

  def check_win_comp
    if @player_maker.comp_input_code == @player_maker.player_input_code
      @turn_count = 13
      @winner = true
    end
  end

  def result
    case @player_choice
    when "1"
      if @winner == true
        puts "Congratulations, you solved it!"
      else
        puts "The code was #{@secret_code}. Better luck next time!"
      end
    else
      if @winner == true
        puts "The machine figured out your code!"
      else
        puts "You beat the machine!"
      end
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
