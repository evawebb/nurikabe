def get_deltas(dist, diag)
  if dist == 1
    if diag
      [
        [-1, -1],
        [-1, 0],
        [-1, 1],
        [0, -1],
        [0, 1],
        [1, -1],
        [1, 0],
        [1, 1]
      ]
    else
      [
        [-1, 0],
        [0, -1],
        [0, 1],
        [1, 0]
      ]
    end
  elsif dist == 2
    [
      [-2, 0],
      [-1, -1],
      [-1, 1],
      [0, -2],
      [0, 2],
      [1, -1],
      [1, 1],
      [2, 0]
    ]
  end
end

def neighbors(puzzle, x, y, dist = 1, diag = false)
  deltas = get_deltas(dist, diag)
  deltas.each do |dx, dy|
    nx = x + dx
    ny = y + dy
    if (
      ny >= 0 &&
      nx >= 0 &&
      ny < puzzle.size &&
      nx < puzzle[ny].size
    )
      yield(nx, ny)
    end
  end
end

def is_number(puzzle, x, y)
  puzzle[y][x] != "_" &&
  puzzle[y][x] != "#" &&
  puzzle[y][x] != "."
end

def print_puzzle(puzzle)
  print "+-"
  puzzle[0].size.times { print "---" }
  print "-+"
  puts

  puzzle.each do |row|
    print "| "
    row.each do |c|
      print sprintf("%2s ", c.to_s)
    end
    print " |"
    puts
  end

  print "+-"
  puzzle[0].size.times { print "---" }
  print "-+"
  puts
end
