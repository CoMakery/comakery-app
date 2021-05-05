require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'III. Projects' do
  include Rails.application.routes.url_helpers

  before do
    Timecop.freeze(Time.zone.local(2021, 4, 6, 10, 5, 0))
    allow_any_instance_of(Comakery::APISignature).to receive(:nonce).and_return('0242d70898bcf3fbb5fa334d1d87804f')
  end

  after do
    Timecop.return
  end

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }

  let!(:project) { create(:static_project, id: 98, mission: active_whitelabel_mission, token: create(:static_comakery_token, id: 84), account: create(:static_account, id: 100, managed_mission: active_whitelabel_mission)) }

  let!(:project2) { create(:static_project, id: 25, mission: active_whitelabel_mission, token: create(:static_comakery_token, id: 85, name: 'ComakeryToken-6565af0266e546fb62111bbcece711a5b6034a2f', symbol: 'XYZe744a975bde638d8a1a3df7fc39f5afcf4be0358'), account: create(:account, email: 'me+b884e29cbea5f547cc6d2f4e632642d153afbb45@example.com', nickname: 'hunter-ec09c6af6ea2846f4d0e09690dc00c3f7878165g', managed_account_id: 'e0510e56-b036-43bf-9e8c-e691a3dc4100', id: 99, managed_mission: active_whitelabel_mission)) }

  before do
    3.times do |n|
      project.admins << create(:account, managed_account_id: "1c182a7b-4f22-4636-9047-8bab3235294#{n}", managed_mission: active_whitelabel_mission)
    end

    project.transfer_types.each_with_index do |t_type, i|
      t_type.update_column(:id, 905 + i) # rubocop:disable Rails/SkipsModelValidations
    end

    project2.transfer_types.each_with_index do |t_type, i|
      t_type.update_column(:id, 1300 + i) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  explanation 'Retrieve projects data.'

  header 'API-Key', build(:api_key)

  get '/api/v1/projects' do
    with_options with_example: true do
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:page) { 1 }

      example 'INDEX' do
        explanation 'Returns an array of projects. See GET for response fields description.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects/:id' do
    with_options with_example: true do
      parameter :id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :id, 'project id', type: :integer
      response_field :title, 'project title', type: :string
      response_field :description, 'proect description', type: :string
      response_field :imageUrl, 'project image url', type: :string
      response_field :accountId, 'project owner account id', type: :string
      response_field :createdAt, 'project creation timestamp', type: :string
      response_field :updatedAt, 'project update timestamp', type: :string

      response_field :adminIds, 'array of admin account ids', type: :array, items: { type: :string }
      response_field :transferTypes, 'array of transfer types', type: :array, items: { type: :string }

      response_field 'token[id]', 'token id', type: :integer
      response_field 'token[name]', 'token name', type: :string
      response_field 'token[symbol]', 'token symbol', type: :string
      response_field 'token[network]', 'token network ( main | ropsten | kovan | rinkeby )', type: :string
      response_field 'token[contractAddress]', 'token contract address', type: :string
      response_field 'token[decimalPlaces]', 'token decimal places', type: :integer
      response_field 'token[logoUrl]', 'token logo url', type: :string
      response_field 'token[createdAt]', 'token creation timestamp', type: :string
      response_field 'token[updatedAt]', 'token update timestamp', type: :string
    end

    context '200' do
      let!(:id) { project.id }

      example 'GET' do
        explanation 'Returns data for a single project.'

        request = build(:api_signed_request, '', api_v1_project_path(id: project.id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end
end
