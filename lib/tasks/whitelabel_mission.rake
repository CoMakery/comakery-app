namespace :mission do
  desc 'Creating a default whitelabel mission on app init'
  task default_whitelabel_mission: :environment do
    new_whitelabel_mission = mission
    new_whitelabel_mission.save(validate: false)
  end

  def mission
    defaults = {
      name: 'test1',
      subtitle: 'test1',
      description: 'test1',
      whitelabel: true,
      whitelabel_domain: ENV['APP_HOST'].presence || 'test.test'
    }
    Mission.new(defaults)
  end
end
