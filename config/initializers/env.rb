def env!(key, default=nil)
  raise "Please set #{key} environment variable" unless ENV.has_key?(key) || default.present?
  if ENV.has_key?(key)
    ENV[key]
  else
    default
  end
end
