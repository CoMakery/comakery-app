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

stats = {}
(0...30).each do |days_ago|
  date = Date.parse(days_ago.days.ago.utc.iso8601)

  day = stats[date] = {}

  results = run %{cd #{repo_path} && git log --pretty="%an" --since="#{days_ago + 1} days ago" --until "#{days_ago} days ago"}, quiet: !$DEBUG

  results.split("\n").each do |name|
    day[name] ||= 0
    day[name] += 1
  end
end

puts "\n" * 3 if $DEBUG
puts JSON.pretty_generate stats, indent: '    '
