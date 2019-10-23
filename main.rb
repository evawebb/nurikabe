#!/usr/bin/ruby

require "pp"
require_relative "tricks.rb"
require_relative "utils.rb"

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

puzzle = []
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
  puzzle << row
end
puzzle = puzzle[1..-1]

print_puzzle(puzzle)
close_numbers(puzzle)
print_puzzle(puzzle)
