# Rubocop gives false positives on empty example groups with rspec_api_documentation DSL

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'V. Transfer Rules' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:transfer_rule) { create(:transfer_rule) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: transfer_rule.token) }

  explanation 'Create and delete transfer rules, retrieve transfer rules data.'

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/projects/:project_id/transfer_rules' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:page) { 1 }

      example 'INDEX' do
        explanation 'Returns an array of transfer rules. See GET for response fields description.'

        request = build(:api_signed_request, '', api_v1_project_transfer_rules_path(project_id: project.id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects/:project_id/transfer_rules/:id' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :id, 'transfer rule id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :id, 'transfer rule id', type: :integer
      response_field :token_id, 'transfer rule token id', type: :integer
      response_field :sending_group_id, 'sending reg group token id', type: :integer
      response_field :receiving_group_id, 'reveiving reg group token id', type: :integer
      response_field :lockup_until, 'lockup until', type: :integer
      response_field :status, 'transfer rule status (created synced)', type: :string
      response_field :createdAt, 'creation timestamp', type: :string
      response_field :updatedAt, 'update timestamp', type: :string
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:id) { transfer_rule.id }

      example 'GET' do
        explanation 'Returns data for a single transfer rule.'

        request = build(:api_signed_request, '', api_v1_project_transfer_rule_path(id: transfer_rule.id, project_id: project.id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/projects/:project_id/transfer_rules' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    with_options scope: :transfer_rule, with_example: true do
      parameter :sending_group_id, 'sending reg group id', required: true, type: :string
      parameter :receiving_group_id, 'receiving reg group id', required: true, type: :string
      parameter :lockup_until, 'lockup until', required: true, type: :string
    end

    context '201' do
      let!(:project_id) { project.id }

      let!(:valid_attributes) do
        {
          sending_group_id: create(:reg_group, token: transfer_rule.token).id.to_s,
          receiving_group_id: create(:reg_group, token: transfer_rule.token).id.to_s,
          lockup_until: '1'
        }
      end

      example 'CREATE' do
        explanation 'Returns created transfer rule details (See GET for response details)'

        request = build(:api_signed_request, { transfer_rule: valid_attributes }, api_v1_project_transfer_rules_path(project_id: project.id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:project_id) { project.id }

      let!(:invalid_attributes) do
        {
          sending_group_id: '945677752'
        }
      end

      example 'CREATE – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { transfer_rule: invalid_attributes }, api_v1_project_transfer_rules_path(project_id: project.id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/projects/:project_id/transfer_rules/:id' do
    with_options with_example: true do
      parameter :id, 'transfer rule id', required: true, type: :integer
      parameter :project_id, 'project id', required: true, type: :integer
    end

    context '200' do
      let!(:id) { transfer_rule.id }
      let!(:project_id) { project.id }

      example 'DELETE' do
        explanation 'Delete the tranfer rule and returns an array of present transfer rules (See GET for response details)'

        request = build(:api_signed_request, '', api_v1_project_transfer_rule_path(id: transfer_rule.id, project_id: project.id), 'DELETE', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end
end
