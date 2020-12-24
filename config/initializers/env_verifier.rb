File.readlines('./.env.required').each do |line|
  var = line.split('=')&.first

  next unless var.present?
  Rails.logger.info "Missing required ENV variable: #{var}" if ENV[var].blank?
end
