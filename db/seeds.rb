require 'refile/file_double'
require_relative '../spec/support/mom.rb'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env.development? || Rails.env.test?
  Specialty.initializer_setup

  Account.create(
    email: 'dev@dev.dev',
    password: 'dev',
    first_name: 'Dev',
    last_name: 'Devvy',
    date_of_birth: 18.years.ago,
    country: 'United States',
    specialty: Specialty.find_or_create_by(name: 'General'),
    comakery_admin: true
  )

  Token.create(
    name: 'Dummy Token',
    symbol: 'DMT',
    decimal_places: 8,
    _blockchain: 'ethereum_ropsten',
    _token_type: 'erc20',
    contract_address: '0x' + 'a' * 40,
    logo_image: Refile::FileDouble.new('dummy_logo_image', 'logo_image.png', content_type: 'image/png')
  )

  dummy_mission = Mission.create(
    name: 'Dummy Mission',
    subtitle: 'Fake',
    description: 'Created for development',
    image: Refile::FileDouble.new('dummy_image', 'image.png', content_type: 'image/png'),
    logo: Refile::FileDouble.new('dummy_logo', 'logo.png', content_type: 'image/png')
  )

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
    square_image: Refile::FileDouble.new('dummy_square_image', 'image.png', content_type: 'image/png'),
    panoramic_image: Refile::FileDouble.new('dummy_panoramic_image', 'image.png', content_type: 'image/png'),
    token: Token.last,
    mission: dummy_mission,
    account: Account.last
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
                         mission: dummy_mission))

  create(:project_with_ready_task,
         name: 'award 3',
         status: 'ready',
         project: create(:project,
                         title: 'Proj 3',
                         visibility: :public_listed,
                         mission: dummy_mission))
end
