require_relative "utils.rb"

def h(point, goal)
  (
    (point[0] - goal[0]).abs +
    (point[1] - goal[1]).abs
  )
end

def routable_neighbors(puzzle, x, y)
  deltas = [
    [-1, 0],
    [0, -1],
    [0, 1],
    [1, 0]
  ]
  out = []

  deltas.each do |d|
    nx = x + d[0]
    ny = y + d[1]
    
    if (
      ny >= 0 &&
      nx >= 0 &&
      ny < puzzle[:grid].size &&
      nx < puzzle[:grid][ny].size &&
      puzzle[:grid][ny][nx] == "_"
    )
      out << [nx, ny]
    end
  end

  out
end

# TODO: rewrite with the clone_puzzle function
def alter_puzzle(puzzle, start_cluster_status)
  altered_puzzle = { :grid => [] }
  puzzle[:grid].each_index do |y|
    row = []
    puzzle[:grid][y].each_index do |x|
      if (
        (
          is_number(puzzle, x, y) || 
          puzzle[:grid][y][x] == "."
        ) &&
        start_cluster_status["."].include?([x, y])
      )
        row << "_"
      else
        island_neighbor = false
        neighbors(puzzle, x, y) do |nx, ny|
          if (
            (
              is_number(puzzle, nx, ny) ||
              puzzle[:grid][ny][nx] == "."
            ) &&
            !start_cluster_status["."].include?([nx, ny])
          )
            island_neighbor = true
            break
          end
        end

        if island_neighbor
          row << "#"
        else
          row << puzzle[:grid][y][x]
        end
      end
    end
    altered_puzzle[:grid] << row
  end

  altered_puzzle
end

def route(puzzle, x1, y1, x2, y2)
  start_cluster_status = get_cluster_status(puzzle, x1, y1)
  altered_puzzle = if start_cluster_status["type"] == "."
    alter_puzzle(puzzle, start_cluster_status)
  else
    puzzle
  end

  start = [x1, y1]
  goal = [x2, y2]

  frontier = [start]
  gs = { start => 0 }
  hs = { start => h(start, goal) }

  backtrace = {}

  while !frontier.empty?
    next_point = frontier.pop

    routable_neighbors(altered_puzzle, next_point[0], next_point[1]).each do |neighbor|
      g_score = gs[next_point] + 1
      if gs.has_key?(neighbor)
        if gs[neighbor] > g_score
          gs[neighbor] = g_score
          backtrace[neighbor] = next_point
        end
      else
        gs[neighbor] = g_score
        hs[neighbor] = h(neighbor, goal)
        backtrace[neighbor] = next_point
        frontier << neighbor
      end
    end

    frontier.sort! do |a, b|
      gs[a] + hs[a] <=> gs[b] + gs[b]
    end

    if next_point == goal
      route = [goal]
      while true
        back = backtrace[route[-1]]
        route << back
        if back == start
          break
        end
      end
      return route.reverse
    end
  end

  return nil
end
