#!/usr/bin/ruby

require "pp"
require_relative "tricks.rb"
require_relative "utils.rb"
require_relative "route.rb"

puzzle_raw = %{
,,,,,
,,5,,,
,1,,2,,
,,,,,4
5,,,,,
,,2,,1,
,,,,,3
,,,,,
}

puzzle = {
  :grid => []
}
puzzle_raw.each_line do |l|
  row = l.split(",").map { |s| s.strip }
  row = row.map do |s|
    if s.empty?
      "_"
    elsif s =~ /^\d+$/
      s.to_i
    else
      s
    end
  end
  puzzle[:grid] << row
end
puzzle[:grid] = puzzle[:grid][1..-1]

old_puzzle = clone_puzzle(puzzle)
print_puzzle(puzzle)
while trick_loop(puzzle)
  print_puzzle(puzzle, nil, old_puzzle)
old_puzzle = clone_puzzle(puzzle)
end
print_puzzle(puzzle, nil, old_puzzle)

