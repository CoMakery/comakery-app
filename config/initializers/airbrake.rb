def configure_airbrake

  if ENV['AIRBRAKE_API_KEY'].blank? || ENV['AIRBRAKE_PROJECT_ID'].blank? ||
          ENV['APP_NAME'].blank?
    Rails.logger.error '!' * 50
    Rails.logger.error "Error reporting is not set up! " \
      "Please set ENV['AIRBRAKE_API_KEY'] and ENV['AIRBRAKE_PROJECT_ID'] and " \
      "ENV['APP_NAME'] " \
      "See: https://github.com/airbrake/airbrake-ruby#project_id--project_key"
    return
  end

  Airbrake.configure do |c|
    c.project_id = ENV['AIRBRAKE_PROJECT_ID']
    c.project_key = ENV['AIRBRAKE_API_KEY']

    c.root_directory = Rails.root
    c.logger = Rails.logger
    c.environment = ENV['APP_NAME']

    # A list of parameters that should be filtered out of what is sent to
    # Airbrake. By default, all "password" attributes will have their contents
    # replaced.
    # https://github.com/airbrake/airbrake-ruby#blacklist_keys
    c.blacklist_keys = [
      /password/i,
      /api_?key/i,
    ]
  end

  # If Airbrake doesn't send any expected exceptions, we suggest to uncomment the
  # line below. It might simplify debugging of background Airbrake workers, which
  # can silently die.
  # Thread.abort_on_exception = ['test', 'development'].include?(Rails.env)
end

configure_airbrake if Rails.application.config.airbrake
