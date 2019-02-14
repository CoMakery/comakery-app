require 'refile/file_double'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env == 'development'
  Account.create(
    email: 'dev@dev.dev',
    password: 'dev',
    first_name: 'Dev',
    last_name: 'Devvy',
    date_of_birth: 18.years.ago,
    country: 'United States of America',
    comakery_admin: true
  )

  Token.create(
    name: 'Dummy Token',
    symbol: 'DMT',
    decimal_places: 8,
    ethereum_network: 'ropsten',
    ethereum_contract_address: '0x' + 'a' * 40,
    coin_type: 'erc20'
  )

  Mission.create(
    name: 'Dummy Mission',
    subtitle: 'Fake',
    description: 'Created for development',
    image: Refile::FileDouble.new('dummy_image', 'image.png', content_type: 'image/png'),
    logo: Refile::FileDouble.new('dummy_logo', 'logo.png', content_type: 'image/png')
  )

  Project.create(
    title: 'Dummy Project',
    description: 'Created for development',
    tracker: 'https://github.com/CoMakery/comakery-app',
    royalty_percentage: 5.9,
    maximum_royalties_per_month: 10_000,
    legal_project_owner: 'Dummy Inc',
    require_confidentiality: false,
    exclusive_contributions: false,
    visibility: 'member',
    long_id: SecureRandom.hex(20),
    maximum_tokens: 10_000_000,
    image: Refile::FileDouble.new('dummy_image', 'image.png', content_type: 'image/png'),
    account: Account.last
  )
end
