#!/usr/bin/env ruby
#
# Usage: git-stats.rb path/to/repo > repo.json
#
# Verbose debugging: ruby -d git-stats.rb path/to/repo
#

require 'active_support/all'
require 'json'
require 'easy_shell'

repo_path = ARGV[-1] || '.'

TOO_SMALL_CONTRIBUTION = 0  # used to trim dataset to managable size
DAYS_OF_HISTORY = 30
BOTS = %w[ greenkeeperio-bot ]

stats = {}
(0...DAYS_OF_HISTORY).each do |days_ago|
  date = Date.parse(days_ago.days.ago.utc.iso8601)

  day = stats[date] = {}

  results = run %{cd #{repo_path} && git log --pretty="%an" --since="#{days_ago + 1} days ago" --until "#{days_ago} days ago"}, quiet: !$DEBUG
  next if results.blank?
  results.split("\n").each do |names|
    # handle pair programmers: split name on ' and ' or ' & ' or ', '
    names.split(/,\s*|\s+and\s+|\s+&\s+/).each do |name|
      unless BOTS.include? name
        day[name] ||= 0
        day[name] += 1
      end
    end
  end
end

# delete if no data for that day
stats.delete_if { |day, data| data.blank? }

# delete if contribution too small
stats.each do |day, data|
  data.delete_if { |key, value| value <= TOO_SMALL_CONTRIBUTION }
end

puts "\n" * 3 if $DEBUG
puts JSON.pretty_generate stats, indent: '    '
