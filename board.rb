
class Board
  attr_accessor :grid

  def initialize(dupped = false)
    @grid = Array.new(9) { Array.new(9) { nil } } 
    self.create_puzzle unless dupped 
    self.shroud_puzzle unless dupped 
  end

  def box(num)
    sub_grid = []
    row1 = (num/3 * 3) 
    row2 = (num/3 * 3) + 1
    row3 = (num/3 * 3) + 2

    start_point = (num % 3 * 3) 
    end_point = (num % 3 * 3) + 2

    sub_grid += @grid[row1][start_point..end_point] + @grid[row2][start_point..end_point] + @grid[row3][start_point..end_point]
    sub_grid.compact
  end

  def grab_box(x,y)
    box = (x/3) * 3 + (y/3) 
  end


  def display
    puts
    box_counter = 1 
    @grid.each_with_index do |box, b|
      row_counter = 1 
      box.each_index do |i|
        if @grid[b][i] == nil
          print "_|"
        else
          print @grid[b][i].to_s + "|"
        end
        print " " if row_counter % 3 == 0 
        puts "" if row_counter % 9 == 0 
        row_counter += 1
      end
      puts "" if box_counter % 3 == 0 
      box_counter += 1
    end
  end


  def solve
    no_advances = false

    until no_advances 
      no_advances = true
      @grid.each_with_index do |row, x|
        row.each_index do |y|
          remaining = remaining_for_spot(x,y)
          if remaining.size == 1
            @grid[x][y] = remaining[0] 
            no_advances = false
          end
        end
      end
    end
  end

  def remaining_for_section(loc, type)
    # loc is digit 0-8 
    # type is "box" "row" or "column"
    # returns an array of digits 1-9 for remaining available numbers for the type of section
    results = [1,2,3,4,5,6,7,8,9]

    @grid.each_with_index do |row, x|
      if type == "row"
        next if x != loc
      end
      row.each_index do |y|
        if type == "column"
          next if y != loc
        end
        results.delete_if { |num| num == @grid[x][y] }
      end
    end
 
    if type == "box"
      box(loc).each do |counted|
        results.delete_if { |num| num == counted }
      end
    end

    results
  end


  def remaining_for_spot(x,y)
    spot = @grid[x][y]
    results = [1,2,3,4,5,6,7,8,9]
    box_num = grab_box(x,y)

    return [] if results.include?(spot)

    r = remaining_for_section(x, "row")
    c = remaining_for_section(y, "column")
    b = self.box(box_num)

    results.delete_if { |num| !r.include?(num) }
    results.delete_if { |num| !c.include?(num) }
    results.delete_if { |num| b.include?(num) }

    results
  end

  def create_puzzle
    until self.complete?
      self.solve #make sure game was solved before random addition
      self.add_random_square
      self.solve #attempt to solve game after random addition
    end
    self.display
  end

  def shroud_puzzle
    change_counter = 0
    while self.open_spots.size < 60
      p self.open_spots.size
      last_change = self.open_spots.size
      closed = self.closed_spots.sample
      x = closed[0]
      y = closed[1]
      spot = @grid[x][y]
      @grid[x][y] = nil
      clone = self.dup
      unless clone.solvable?
        @grid[x][y] = spot 
        change_counter += 1
      end
      change_counter = 0 if self.open_spots.size != last_change
      break if change_counter > 50 
    end
  end

  def solvable?
    self.solve
    self.complete?
  end

  def dup
    new_board = Board.new(true)

    new_board.grid = Array.new(9) { Array.new(9) { nil } } 
    @grid.each_with_index do |row, x|
      row.each_index do |y|
        new_board.grid[x][y] = @grid[x][y]
      end
    end

    new_board
  end

  def add_random_square
    # should not call until solved up until this point, otherwise will cause incorrect puzzle
    randoms = []
    @grid.each_with_index do |row, x|
      row.each_index do |y|
        randoms << [x, y] if @grid[x][y] == nil
      end
    end
    rspot = randoms.sample
    remaining = remaining_for_spot(rspot[0],rspot[1])
    @grid[rspot[0]][rspot[1]] = remaining.sample 

    if self.valid? == false 
      self.clear_grid
    end

    @grid[rspot[0]][rspot[1]]
  end

  def complete?
    # tells you whether all the spots are filled, not necessarily valid
    @grid.flatten.none? { |spot| spot == nil }
  end

  def open_spots
    randoms = []
    @grid.each_with_index do |row, x|
      row.each_index do |y|
        randoms << [x, y] if @grid[x][y] == nil
      end
    end
    randoms
  end

  def closed_spots
    closed = []
    @grid.each_with_index do |row, x|
      row.each_index do |y|
        closed << [x, y] if @grid[x][y] != nil
      end
    end
    closed
  end

  def valid?
    # gets remaining open spots
    # returns whether all spots have at least one remaining number
    spots = self.open_spots
    spots.all? { |spot| remaining_for_spot(spot[0],spot[1]).size > 0 }
  end

  def clear_grid 
    @grid.each_with_index do |row, x|
      row.each_index do |y|
        @grid[x][y] = nil
      end
    end
  end

end

