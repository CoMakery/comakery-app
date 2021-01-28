namespace :whitelabel_mission do
  desc 'Creating a default whitelabel mission on app deploy to heroku'
  task create_default: :environment do
    message_and_exit('== Skip creation because `WHITELABEL` env is not true ==') if ENV['WHITELABEL'] != 'true'

    domain = ENV['APP_HOST'].presence || 'wl.comakery.com'
    mission_for_domain = Mission.where(whitelabel: true, whitelabel_domain: domain)
    message_and_exit("== Skip creation because whitelabel mission for #{domain} domain already exists ==") if mission_for_domain.exists?

    title = "Whitelabel mission for #{domain}"
    Mission.new(
      name: title,
      subtitle: title,
      description: title,
      whitelabel: true,
      whitelabel_domain: domain,
      logo: { io: File.open(Rails.root.join('app/assets/images/defaults/mission_logo.png').to_s), filename: 'mission_logo.png' },
      image: { io: File.open(Rails.root.join('app/assets/images/defaults/mission_image.png').to_s), filename: 'mission_image.png' }
    ).save!
  end

  def message_and_exit(message)
    Rails.logger.info message
    exit
  end
end
