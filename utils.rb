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

def scan_puzzle(puzzle)
  puzzle.each_index do |y|
    puzzle[y].each_index do |x|
      yield(x, y)
    end
  end
end

def get_cluster_status(puzzle, x, y)
  if puzzle[y][x] == "_"
    return nil
  else
    type = "."
    border = "#"
    if puzzle[y][x] == "#"
      type = "#"
      border = "."
    end

    out = {
      "type" => type,
      "origin" => nil,
      "." => [],
      "#" => [],
      "_" => []
    }

    if type == "." && is_number(puzzle, x, y)
      out["origin"] = [x, y]
    end

    out[type] << [x, y]
    data_size = 0
    new_data_size = 1

    while new_data_size > data_size
      data_size = new_data_size

      out[type].each do |pt|
        neighbors(puzzle, pt[0], pt[1]) do |nx, ny|
          is_type = (
            (type == "." && (is_number(puzzle, nx, ny) || puzzle[ny][nx] == ".")) ||
            (type == "#" && puzzle[ny][nx] == "#")
          )
          is_border = (
            (border == "." && (is_number(puzzle, nx, ny) || puzzle[ny][nx] == ".")) ||
            (border == "#" && puzzle[ny][nx] == "#")
          )

          if is_type && !out[type].include?([nx, ny])
            out[type] << [nx, ny]
            new_data_size += 1
            
            if type == "." && is_number(puzzle, nx, ny)
              out["origin"] = [nx, ny]
            end
          elsif is_border && !out[border].include?([nx, ny])
            out[border] << [nx, ny]
            new_data_size += 1
          elsif puzzle[ny][nx] == "_" && !out["_"].include?([nx, ny])
            out["_"] << [nx, ny]
            new_data_size += 1
          end
        end
      end
    end

    out
  end
end
