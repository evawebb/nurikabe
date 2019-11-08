require_relative "utils.rb"

def trick_loop(puzzle)
  total_island_before = 0
  total_water_before = 0
  scan_puzzle(puzzle) do |x, y|
    if puzzle[:grid][y][x] == "."
      total_island_before += 1
    elsif puzzle[:grid][y][x] == "#"
      total_water_before += 1
    end
  end

  close_islands(puzzle)
  obvious_islands(puzzle)
  escaping_water(puzzle)
  cornered_island(puzzle)
  restricted_spaces(puzzle)

  total_island_after = 0
  total_water_after = 0
  scan_puzzle(puzzle) do |x, y|
    if puzzle[:grid][y][x] == "."
      total_island_after += 1
    elsif puzzle[:grid][y][x] == "#"
      total_water_after += 1
    end
  end

  (total_island_before != total_island_after) || (total_water_before != total_water_after)
end

def close_islands(puzzle)
  scan_puzzle(puzzle) do |x, y|
    primary_cluster_status = get_cluster_status(puzzle, x, y)
    if (
      !primary_cluster_status.nil? && 
      !primary_cluster_status["origin"].nil? && 
      primary_cluster_status["type"] == "."
    )
      neighbors(puzzle, x, y, dist = 2) do |nx, ny|
        secondary_cluster_status = get_cluster_status(puzzle, nx, ny)
        if (
          !secondary_cluster_status.nil? &&
          !secondary_cluster_status["origin"].nil? &&
          secondary_cluster_status["type"] == "." &&
          secondary_cluster_status["origin"] != primary_cluster_status["origin"]
        )
          if x == nx
            puzzle[:grid][(y + ny) / 2][nx] = "#"
          elsif y == ny
            puzzle[:grid][ny][(x + nx) / 2] = "#"
          else
            puzzle[:grid][ny][x] = "#"
            puzzle[:grid][y][nx] = "#"
          end
        end
      end
    end
  end
end

def obvious_islands(puzzle)
  each_number(puzzle) do |x, y|
    if puzzle[:grid][y][x] == 1
      neighbors(puzzle, x, y) do |nx, ny|
        puzzle[:grid][ny][nx] = "#"
      end
    else
      cluster_status = get_cluster_status(puzzle, x, y)
      if cluster_status["."].size == puzzle[:grid][y][x] && cluster_status["_"].size > 0
        cluster_status["_"].each do |pt|
          puzzle[:grid][pt[1]][pt[0]] = "#"
        end
      elsif cluster_status["_"].size == 1
        free_cell = cluster_status["_"][0]
        puzzle[:grid][free_cell[1]][free_cell[0]] = "."
      end
    end
  end
end

def escaping_water(puzzle)
  total_water = 0
  scan_puzzle(puzzle) do |x, y|
    if puzzle[:grid][y][x] == "#"
      total_water += 1
    end
  end

  scan_puzzle(puzzle) do |x, y|
    if puzzle[:grid][y][x] == "#"
      cluster_status = get_cluster_status(puzzle, x, y)
      if cluster_status["_"].size == 1 && cluster_status["#"].size < total_water
        free_cell = cluster_status["_"][0]
        puzzle[:grid][free_cell[1]][free_cell[0]] = "#"
      end
    end
  end
end

def cornered_island(puzzle)
  each_number(puzzle) do |x, y|
    cluster_status = get_cluster_status(puzzle, x, y)
    if cluster_status["."].size + 1 == puzzle[:grid][y][x] && cluster_status["_"].size == 2
      free_cells = cluster_status["_"]
      if (free_cells[0][0] - free_cells[1][0]).abs == 1 && (free_cells[0][1] - free_cells[1][1]).abs == 1
        if puzzle[:grid][free_cells[0][1]][free_cells[1][0]] == "_"
          puzzle[:grid][free_cells[0][1]][free_cells[1][0]] = "#"
        elsif puzzle[:grid][free_cells[1][1]][free_cells[0][0]] == "_"
          puzzle[:grid][free_cells[1][1]][free_cells[0][0]] = "#"
        end
      end
    end
  end
end

def restricted_spaces(puzzle)
  each_number(puzzle) do |x, y|
    cluster_status = get_cluster_status(puzzle, x, y)
    if cluster_status["_"].size > 0 
      possible_free_cells = []
      scan_puzzle(puzzle) do |nx, ny|
        if puzzle[:grid][ny][nx] == "_" && !route(puzzle, x, y, nx, ny).nil?
          possible_free_cells << [nx, ny]
        end
      end

      if possible_free_cells.size > 0 && possible_free_cells.size < 5
        cells_left = puzzle[:grid][y][x] - cluster_status["."].size
        patches = all_possible_patches(possible_free_cells, cells_left)

        maybe_land = {}
        maybe_water = {}
        possible_free_cells.each do |p|
          maybe_land[p] = false
          maybe_water[p] = false
        end

        patches.each do |patch|
          if valid?(clone_puzzle(puzzle, patch))
            patch.each do |p, type|
              if type == "."
                maybe_land[p] = true
              elsif type == "#"
                maybe_water[p] = true
              end
            end
          end
        end

        possible_free_cells.each do |p|
          if maybe_land[p] && !maybe_water[p]
            puzzle[:grid][p[1]][p[0]] = "."
          elsif maybe_water[p] && !maybe_land[p]
            puzzle[:grid][p[1]][p[0]] = "#"
          end
        end
      end
    end
  end
end
