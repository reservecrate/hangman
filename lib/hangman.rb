require 'yaml'

class Hangman
  def initialize
    @secret_word = get_random_word
    @num_guesses = @secret_word.size * 2
    @guess_state_ary = Array.new(@secret_word.size) { '_' }
    @guess = ''
    @file_name = ''
  end

  def run_game
    if load_saved_game?
      load_saved_game
      save_game? ? run_with_save : run_without_save
    else
      save_game? ? run_with_save : run_without_save
    end
    puts @num_guesses == 0 ? "You lost! The secret word was: #{@secret_word}" : "You won! The secret word was: #{@secret_word}"
  end

  private
  def run_with_save
    print 'Enter file name (without extension): '
      @file_name = gets.gsub(/\s+/, '')
      until @guess_state_ary.join == @secret_word or @num_guesses == 0
        display_guess_state
        get_user_input
        update_guess_state
        @num_guesses -= 1
        puts "Remaining guesses: #{@num_guesses}"
        save_game
    end
  end

  def run_without_save
    until @guess_state_ary.join == @secret_word or @num_guesses == 0
        display_guess_state
        get_user_input
        update_guess_state
        @num_guesses -= 1
        puts "Remaining guesses: #{@num_guesses}"
    end
  end

  def display_guess_state
    puts @guess_state_ary.join(' ')
  end

  def update_guess_state
    @secret_word.split('').each_with_index do |c, i|
      @guess_state_ary[i] = c if c == @letter
    end
  end

  def save_game?
    print 'Do you want to automatically save the game? (y/*) '
    user_choice = gets.strip.downcase
    user_choice == 'y' ? true : false
  end

  def save_game
    game_state = { secret_word: @secret_word, num_guesses: @num_guesses, guess_state: @guess_state_ary }
    File.open("#{@file_name}.yaml", 'w') { |f| f.write(game_state.to_yaml) }
  end

  def load_saved_game?
    print 'Do you want to load a previously saved game? (y/*) '
    user_choice = gets.strip.downcase
    user_choice == 'y' ? true : false
  end

  def load_saved_game
    print 'Enter file name (without extension): '
    file_name = gets.gsub(/\s+/, '')
    game_state = YAML.load(File.read("#{file_name}.yaml"))
    @secret_word = game_state[:secret_word]
    @num_guesses = game_state[:num_guesses]
    @guess_state_ary = game_state[:guess_state]
  end

  def get_user_input
    loop do
      print 'Enter letter: '
      @letter = gets.chomp
      break if valid_input?(@letter)
      puts 'Invalid input entered - please try again'
    end
  end

  def valid_input? str
    /^[A-Za-z]$/.match?(str)
  end

  def get_random_word
    file = File.open('google-10000-english-no-swears.txt', 'r')
    words_ary = file.readlines(chomp: true)
    valid_words = words_ary.select { |w| w.size.between?(5, 12) }
    file.close
    valid_words.sample
  end
end

hangman_board = Hangman.new
hangman_board.run_game
