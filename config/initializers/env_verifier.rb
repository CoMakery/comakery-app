File.readlines('./.env.required').each do |line|
  var = line.split('=')&.first

  next unless var.present?
  raise "Missing required ENV variable: #{var}" if ENV[var].blank?
end
