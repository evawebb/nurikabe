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
      ny < puzzle.size &&
      nx < puzzle[ny].size &&
      puzzle[ny][nx] == "_"
    )
      out << [nx, ny]
    end
  end

  out
end

def route(puzzle, x1, y1, x2, y2)
  start = [x1, y1]
  goal = [x2, y2]

  frontier = [start]
  gs = { start => 0 }
  hs = { start => h(start, goal) }

  backtrace = {}

  while !frontier.empty?
    next_point = frontier.pop

    routable_neighbors(puzzle, next_point[0], next_point[1]).each do |neighbor|
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

    # puts next_point.inspect
    # puts routable_neighbors(puzzle, next_point[0], next_point[1]).inspect
    # puts frontier.inspect
    # puts gs.inspect
    # puts hs.inspect
    # puts backtrace.inspect
    # puts

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
