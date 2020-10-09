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

DAYS_OF_HISTORY = 365 * 2
BOTS = %w[greenkeeperio-bot].freeze

def d(args)
  p args if $DEBUG
end

stats = {}
(0...DAYS_OF_HISTORY).each do |days_ago|
  date = Date.parse(days_ago.days.ago.utc.iso8601)
  results = run %(cd #{repo_path} && git log --pretty="%an" --since="#{days_ago + 1} days ago" --until "#{days_ago} days ago"), quiet: !$DEBUG
  next if results.blank?

  d date
  day = stats[date] = {}
  results.split("\n").each do |names|
    d 'names: ' + names
    # handle pair programmers: split name on ' and ' or ' & ' or ', '
    names.split(/,\s*|\s+and\s+|\s+&\s+/).each do |name|
      d 'name:  ' + name
      unless BOTS.include?(name)
        day[name] ||= 0
        day[name] += 1
      end
    end
  end
end

puts "\n" * 3 if $DEBUG
puts JSON.pretty_generate stats, indent: '    '
