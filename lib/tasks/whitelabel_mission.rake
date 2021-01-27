namespace :mission do
  desc 'Creating a default whitelabel mission on app deploy to heroku'
  task create_default_whitelabel_mission: :environment do
    domain = ENV['APP_HOST'].presence || 'wl.comakery.com'
    mission_for_domain = Mission.where(whitelabel: true, whitelabel_domain: domain)
    if mission_for_domain.exists?
      Rails.logger.info "== Skip creation because whitelabel mission for #{domain} domain already exists =="
      exit
    end

    title = "Whitelabel mission for #{domain}"
    Mission.new(
      name: title,
      subtitle: title,
      description: title,
      whitelabel: true,
      whitelabel_domain: domain
    ).save!
  end
end
