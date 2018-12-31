require "yaml"

class Game
    attr_reader :player

    def initialize(player, corrects=[], misses=[], word=self.class.random_word)
        @player = player
        @word = word
        @corrects = corrects
        @misses = misses
    end

    def guess(letter)
        if @word.include?(letter)
            @word.chars.each_with_index { |char, i| @corrects[i]=letter if letter == char }
        else
            @misses << letter
        end
    end

    def legal_guess?(letter)
        legal = true
        legal = false if letter.length != 1 || !letter.match(/[a-z]/)
        legal = false if @corrects.any? { |x| x==letter }
        legal = false if @misses.any? { |x| x==letter }
        legal
    end

    def display
        screen = ""        
        screen+="+----+\n|\s\s\s\s|\n|\s\s\s\s"
        head = (@misses[0])? "O" : "\s"
        left_hand = (@misses[1])? "/" : "\s"
        body = (@misses[2])? "|" : "\s"
        right_hand = (@misses[3])? "\\" : "\s"
        left_leg = (@misses[4])? "/" : "\s"
        right_leg = (@misses[5])? "\\" : "\s"
        screen+="#{head}\n|\s\s\s#{left_hand}#{body}#{right_hand}\n"
        screen+="|\s\s\s#{left_leg}\s#{right_leg}\n|\n|________\n"
        @misses.each { |m| screen+="#{m}\s" } if @misses
        screen+="\n"
        @word.chars.length.times { |i| screen+= (@corrects[i])? "#{@corrects[i]}\s" : "_\s" }
        screen+="\n============"
        screen
    end

    def win?
        @word if @corrects.length == @word.length && @corrects.all?
    end

    def lost?
        @word if @misses.length >= 6
    end

    def save(file_name)
        Dir.mkdir("saves") unless Dir.exists?("saves")
        File.open("saves/#{file_name}.save", 'w') do |file|
            file.puts YAML.dump(self)
        end
    end

    def self.load(file_name)
        save = File.open(file_name, 'r')
        YAML.load(save)
    end

    def self.check_save(file_name)
        "saves/#{file_name}.save" if File.exist?("saves/#{file_name}.save")
    end

    def self.random_word
        words = File.readlines "5desk.txt"
        words = words.map { |word| word.downcase.gsub(/[^a-z]/,'') }
        words = words.select { |x| x.length > 4 && x.length < 13 }
        words.sample
    end

end

class GameController
    def initialize(player)
        (player.downcase=="load")? @game = load_game : @game = Game.new(@player)
        play
    end

    def play
        until @game.win? || @game.lost?
            puts "Please enter a letter"
            input = gets.chomp.downcase
            if input == "save"
                save_game
            elsif @game.legal_guess?(input)
                @game.guess(input)
                system "clear"
                puts @game.display
            else
                puts "Please enter one letter that hasn't been guessed before."
            end            
        end
        puts "#{@game.win?}\n#{@game.player}, you guessed it!" if @game.win?
        puts "#{@game.lost?}\nBetter luck next time, #{@game.player}." if @game.lost?
    end

    def save_game
        loop do
            puts "Please name you save file:"
            file_name = gets.chomp.downcase
            if (Game.check_save(file_name))
                puts("Save already exist")
            else 
                @game.save(file_name)
                puts "Game saved."
                break
            end
        end
    end

    def load_game
        loop do
            if Dir.empty?("saves")
                return Game.new("Dave")
            end
            puts "Enter the name of the save you wish to load:"
            file_name = gets.chomp.downcase
            file_path = Game.check_save(file_name)
            if file_path
                return Game.load(file_path)
            else
                puts "There's no matching save file."
            end
        end
    end
end

puts "Welcome to the game of hangman. Please enter your name to start the game. If you wish to load from a save, just type load."
player = gets.chomp

GameController.new(player)

