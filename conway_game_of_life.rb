class Game
    # Main game constructor
    def initialize(name, size, generations, initial_life=nil)
        @name = name
        @generations = generations
        @board = GameBoard.new size, initial_life
        @current_generation = 0
        self.display
        @status = :never_run
        @terminal_states = [:all_dead, :static, :generations_complete]
    end
    
    # Run loop
    def run!
      @status = :running
      self.status
      @generations.times do
        self.next_generation do # update
          self.display  # display (part 1)
          self.status   # display (part 2)
        end
        break if @terminal_states.include? @status # terminate condition
      end
    end
    
    # Run loop step update
    def next_generation
      @status = :running if @status == :never_run
      return @board if @terminal_states.include? @status
      @current_generation += 1
      new_board = self.evolve
      @status = :all_dead if new_board.barren?
      @status = :static   if @board == new_board
      @status = :generations_complete if @current_generation == @generations
      @board = new_board
      if block_given?  # for use within game code
        yield new_board
      else  # for use at command line to step through
        self.display
        self.status
      end
    end
    
    # Step update helper
    def evolve
        new_board = GameBoard.new @board.size, @board.life
        @board.size.times do |i|
            @board.size.times do |j|
                if cell_fate i, j
                    new_board[i,j].live
                else
                    new_board[i,j].die
                end
            end
        end
        new_board
    end
    
    # Step update helper's helper
    def cell_fate(i, j)
        left = [0, i-1].max; right = [i+1, @board.size-1].min
        top = [0, j-1].max; bottom = [j+1, @board.size-1].min
        sum = 0
        for x in (left..right)
            for y in (top..bottom)
                sum += @board[x,y].value if (x != i or y != j)
            end
        end
        (sum == 3 or (sum == 2 and @board[i,j].alive?))
    end
    
    # Display board on turn completion
    def display
      @board.display @current_generation, @name
    end
    
    # Display status on turn completion
    def status
      if @status == :all_dead then puts "Simulation terminated. No more life."
      elsif @status == :static then puts "Simulation terminated. No movement."
      elsif @status == :generations_complete 
        then puts "Simulation terminated. Specified lifetime ended."
      elsif @status == :running then puts "Simulation running..."
      else puts "Simulation has not been run."
      end
      puts
    end
end

class GameBoard
    attr_reader :size
    
    # GameBoard constructor
    def initialize(size, initial_life=nil)
        @size = size
        @board = Array.new(size) {Array.new(size) {Cell.new :dead}}
        self.seed_board initial_life
    end
    
    # Initialize board cell contents
    def seed_board(life)
        if life.nil?
            # randomly seed board
            srand  # seed the random number generator
            indices = []
            @size.times {|x| @size.times {|y| indices << [x,y] }}
            indices.shuffle[0,10].each {|x,y| @board[y][x].live}
        else
            life.each {|x, y| @board[y][x].live}
        end
    end
    
    # Get game board cell contents
    def [](x, y)
        @board[y][x]
    end
    
    def ==(board)
      self.life == board.life
    end
    
    def barren?
        @size.times do |i| 
            @size.times do |j| 
                return false if @board[i][j].alive?
            end
        end
        true
    end
    
    # Game board cell status
    def life
        indices = []
        @size.times do |x|
            @size.times do |y|
                indices << [x,y] if @board[y][x].alive?
            end
        end
        indices
    end
    
    # Display board
    def display(generation, name)
        puts "#{name} (#{size}x#{size}): generation #{generation}"
        @board.each do |row| 
            print '| '
            row.each do |cell| 
                print "#{cell.alive? ? '@' : '.'} "
            end
            puts '|'
        end
    end
    
    # Clear board of life
    def apocalypse
        @board.each do |row|
            row.each do |cell|
                if cell.alive?
                    cell.die
                end
            end
        end
    end
end

class Cell
    # Cell constructor
    def initialize is_alive
        if is_alive.to_s == "dead"
            @is_alive = false
        elsif is_alive.to_s == "alive"
            @is_alive - false
        else
            @is_alive = is_alive
        end
    end
    
    # Is the cell alive?
    def alive?
        @is_alive
    end
    
    # Tell the cell to live
    def live
        @is_alive = true
    end
    
    # Tell the cell to die
    def die
        @is_alive = false
    end
    
    # Get a numeric value for life: 1=alive, 0=dead
    def value
        if self.alive?
            return 1
        else
            return 0
        end
    end
end

# Create a 3x3 blinker pattern and run for 4 generations
game_of_life = Game.new "blinker", 3, 4, [[1,0],[1,1],[1,2]]
game_of_life.run!

# Create a 5x5 glider pattern and run for 8 generations
game_of_life = Game.new "glider", 5, 8, [[1,0],[2,1],[0,2],[1,2],[2,2]]
game_of_life.run!

# Create a random 5x5 pattern and run for 10 generations
game_of_life = Game.new "random", 5, 10
game_of_life.run!

# Create a random 5x5 patter and step through 6 of 10 generations
game_of_life = Game.new "random", 5, 10
game_of_life.next_generation
game_of_life.next_generation
game_of_life.next_generation
game_of_life.next_generation
game_of_life.next_generation
game_of_life.next_generation
