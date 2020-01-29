# Rubocop gives false positives on empty example groups with rspec_api_documentation DSL

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'III. Projects' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: create(:comakery_token), account: create(:account, managed_mission: active_whitelabel_mission)) }
  let!(:project2) { create(:project, mission: active_whitelabel_mission, token: create(:comakery_token), account: create(:account, managed_mission: active_whitelabel_mission)) }

  before do
    3.times { project.admins << create(:account, managed_mission: active_whitelabel_mission) }
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
