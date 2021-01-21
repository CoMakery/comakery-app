require_relative '../../spec/support/mom.rb'

namespace :mission do
  desc 'Creating a default whitelabel mission on app init'
  task default_whitelabel_mission: :environment do
    account = Account.create(
      email: 'dev@dev.dev',
      password: 'dev',
      first_name: 'Dev',
      last_name: 'Devvy',
      date_of_birth: 18.years.ago,
      country: 'United States',
      specialty: Specialty.find_or_create_by(name: 'General'),
      comakery_admin: true
    )

    token = Token.create(
      name: 'Dummy Token',
      symbol: 'DMT',
      decimal_places: 8,
      _blockchain: 'ethereum_ropsten',
      _token_type: 'erc20',
      contract_address: '0x' + 'a' * 40,
      logo_image: dummy_image
    )

    new_whitelabel_mission = mission
    new_whitelabel_mission.save(validate: false)

    dummy_project = Project.create(
      title: 'Dummy Project',
      description: 'Created for development',
      tracker: 'https://github.com/CoMakery/comakery-app',
      legal_project_owner: 'Dummy Inc',
      require_confidentiality: false,
      exclusive_contributions: false,
      visibility: :public_listed,
      long_id: SecureRandom.hex(20),
      maximum_tokens: 10_000_000,
      square_image: dummy_image,
      panoramic_image: dummy_image,
      token: token,
      mission: new_whitelabel_mission,
      account: account
    )
    create(:project_with_ready_task,
           name: 'award 1',
           status: 'ready',
           project: dummy_project)

    create(:project_with_ready_task,
           name: 'award 2',
           status: 'ready',
           project: create(:project,
                           title: 'Proj 2',
                           visibility: :public_listed,
                           mission: new_whitelabel_mission))

    create(:project_with_ready_task,
           name: 'award 3',
           status: 'ready',
           project: create(:project,
                           title: 'Proj 3',
                           visibility: :public_listed,
                           mission: new_whitelabel_mission))
  end
  def mission
    defaults = {
      name: 'test1',
      subtitle: 'test1',
      description: 'test1',
      image: dummy_image,
      logo: dummy_image,
      whitelabel: true,
      whitelabel_domain: ENV['APP_HOST'].presence || 'test.test'
    }
    Mission.new(defaults)
  end
end
