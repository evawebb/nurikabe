require_relative "utils.rb"

def close_numbers(puzzle)
  puzzle.each_index do |y|
    puzzle[y].each_index do |x|
      if is_number(puzzle, x, y)
        neighbors(puzzle, x, y, dist = 2) do |nx, ny|
          if is_number(puzzle, nx, ny)
            puts "#{x}, #{y}, #{nx}, #{ny}"
            if x == nx
              puts "x == nx | #{(x + nx) / 2}, #{ny}"
              puzzle[(y + ny) / 2][nx] = "#"
            elsif y == ny
              puts "y == ny | #{nx}, #{(y + ny) / 2}"
              puzzle[ny][(x + nx) / 2] = "#"
            else
              puts "else    | #{x}, #{ny}"
              puts "else    | #{nx}, #{y}"
              puzzle[ny][x] = "#"
              puzzle[y][nx] = "#"
            end
          end
        end
      end
    end
  end
end

def obvious_islands(puzzle)
end

def unreachable_cells(puzzle)
end
