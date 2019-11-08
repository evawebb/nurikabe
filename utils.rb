require "pp"

def get_print_top(puzzle)
  out = ""

  out << "   "
  out << "  "
  puzzle[:grid][0].size.times do |i|
    out << sprintf("%2d ", i)
  end
  out << "\n"

  out << "   "
  out << "+-"
  puzzle[:grid][0].size.times { out << "---" }
  out << "-+"
  out << "\n"

  out
end

def get_print_row(puzzle, y, route = nil)
  out = ""

  out << sprintf("%2d ", y)
  out << "| "

  puzzle[:grid][y].each_index do |x|
    if !route.nil? && route.include?([x, y])
      out << " * "
    else
      c = puzzle[:grid][y][x]
      out << sprintf("%2s ", c.to_s)
    end
  end
  out << " |"
  out << "\n"

  out
end

def get_print_bottom(puzzle)
  out = ""

  out << "   "
  out << "+-"
  puzzle[:grid][0].size.times { out << "---" }
  out << "-+"
  out << "\n"

  out
end

def print_puzzle(puzzle, route = nil)
  print get_print_top(puzzle)

  puzzle[:grid].each_index do |y|
    print get_print_row(puzzle, y, route)
  end

  print get_print_bottom(puzzle)
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
      ny < puzzle[:grid].size &&
      nx < puzzle[:grid][ny].size
    )
      yield(nx, ny)
    end
  end
end

def is_number(puzzle, x, y)
  puzzle[:grid][y][x] != "_" &&
  puzzle[:grid][y][x] != "#" &&
  puzzle[:grid][y][x] != "."
end

def scan_puzzle(puzzle)
  puzzle[:grid].each_index do |y|
    puzzle[:grid][y].each_index do |x|
      yield(x, y)
    end
  end
end

def each_number(puzzle)
  scan_puzzle(puzzle) do |x, y|
    if is_number(puzzle, x, y)
      yield(x, y)
    end
  end
end

def get_cluster_status(puzzle, x, y)
  if puzzle[:grid][y][x] == "_"
    return nil
  else
    type = "."
    border = "#"
    if puzzle[:grid][y][x] == "#"
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
            (type == "." && (is_number(puzzle, nx, ny) || puzzle[:grid][ny][nx] == ".")) ||
            (type == "#" && puzzle[:grid][ny][nx] == "#")
          )
          is_border = (
            (border == "." && (is_number(puzzle, nx, ny) || puzzle[:grid][ny][nx] == ".")) ||
            (border == "#" && puzzle[:grid][ny][nx] == "#")
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
          elsif puzzle[:grid][ny][nx] == "_" && !out["_"].include?([nx, ny])
            out["_"] << [nx, ny]
            new_data_size += 1
          end
        end
      end
    end

    out
  end
end

def clone_puzzle(puzzle, alterations = {})
  cloned = { :grid => [] }

  puzzle[:grid].each do |row|
    r = []
    row.each do |cell|
      r << cell
    end
    cloned[:grid] << r
  end

  alterations.each do |coord, value|
    cloned[:grid][coord[1]][coord[0]] = value
  end
  
  cloned
end

def valid?(puzzle)
  valid = true

  # Check for any isolated lakes
  total_water = 0
  scan_puzzle(puzzle) do |x, y|
    if puzzle[:grid][y][x] == "#"
      total_water += 1
    end
  end
  scan_puzzle(puzzle) do |x, y|
    cluster_status = get_cluster_status(puzzle, x, y)
    if (
      !cluster_status.nil? &&
      cluster_status["type"] == "#" && 
      cluster_status["_"].empty? &&
      cluster_status["#"].size < total_water
    )
      valid = false
    end
  end

  # Check for correctly-sized islands
  each_number(puzzle) do |x, y|
    cluster_status = get_cluster_status(puzzle, x, y)
    if (
      cluster_status["."].size > puzzle[:grid][y][x] ||
      (cluster_status["_"].empty? && cluster_status["."].size != puzzle[:grid][y][x])
    )
      valid = false
    end
  end

  valid
end
