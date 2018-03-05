require 'simplecov'
require 'active_support/core_ext/numeric/time'

module SimpleCovEnv
  def start!
    return unless ENV['SIMPLECOV']
    group = ENV['SIMPLECOV_GROUP']

    file_ext = group =~ %r{^views/} ? '.html.rb' : '.rb'
    file_under_test = group.sub(/_spec\.rb$/, file_ext)
    path = File.join('app', file_under_test)
    abs_path = Rails.root.join(path)

    unless File.exist?(abs_path)
      raise "Spec could not find similarly named file under test:\n" \
            "`spec/#{group}` -- expected to find:\n" \
            " `#{path}`      -- but does not exist"
    end

    SimpleCov.start do
      command_name 'specs'

      coverage_dir "coverage/#{group}"

      # Always track:
      track_files abs_path

      # Reject all other files
      add_filter { |file| file.filename !~ /^#{abs_path}/ }

      # For now, generate all reports for double checking
      # at_exit do
      #   # Don't generate formatted reports -- only generate .resultset.json
      #   SimpleCov.result
      # end
    end
  end

  module_function :start!
end
