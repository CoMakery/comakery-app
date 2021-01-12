require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'VI. Account Token Records' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account_token_record) { create(:account_token_record) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: account_token_record.token) }

  before do
    project.safe_add_interested(account_token_record.account)
  end

  explanation 'Create and delete account token records, retrieve account token record data.'

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/projects/:project_id/account_token_records' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:page) { 1 }

      example 'INDEX' do
        explanation 'Returns an array of account token records. See GET for response fields description.'

        request = build(:api_signed_request, '', api_v1_project_account_token_records_path(project_id: project.id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects/:project_id/account_token_records/:id' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :id, 'account token record id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :id, 'account token record id', type: :integer
      response_field :account_id, 'account id', type: :integer
      response_field :token_id, 'token id', type: :integer
      response_field :reg_group_id, 'reg group id', type: :integer
      response_field :lockup_until, 'lockup until', type: :integer
      response_field :max_balance, 'max balance', type: :integer
      response_field :account_frozen, 'account frozen', type: :bool
      response_field :status, 'account token record status (created synced)', type: :string
      response_field :createdAt, 'creation timestamp', type: :string
      response_field :updatedAt, 'update timestamp', type: :string
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:id) { account_token_record.id }

      example 'GET' do
        explanation 'Returns data for a single account token record.'

        request = build(:api_signed_request, '', api_v1_project_account_token_record_path(id: account_token_record.id, project_id: project.id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/projects/:project_id/account_token_records' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    with_options scope: :account_token_record, with_example: true do
      parameter :max_balance, 'max balance', required: true, type: :string
      parameter :lockup_until, 'lockup until', required: true, type: :string
      parameter :reg_group_id, 'reg group id', required: true, type: :string
      parameter :account_id, 'account id', required: true, type: :string
      parameter :account_frozen, 'frozen', required: true, type: :string
    end

    context '201' do
      let!(:project_id) { project.id }

      let!(:valid_attributes) do
        {
          max_balance: '100',
          lockup_until: '1',
          reg_group_id: create(:reg_group, token: account_token_record.token).id.to_s,
          account_id: create(:account).id.to_s,
          account_frozen: 'false'
        }
      end

      example 'CREATE' do
        explanation 'Returns created account token record details (See GET for response details)'

        request = build(:api_signed_request, { account_token_record: valid_attributes }, api_v1_project_account_token_records_path(project_id: project.id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:project_id) { project.id }

      let!(:invalid_attributes) do
        {
          max_balance: '-100',
          lockup_until: '1',
          reg_group_id: create(:reg_group, token: account_token_record.token).id.to_s,
          account_id: create(:account).id.to_s,
          account_frozen: 'false'
        }
      end

      example 'CREATE – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { account_token_record: invalid_attributes }, api_v1_project_account_token_records_path(project_id: project.id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/projects/:project_id/account_token_records/:id' do
    with_options with_example: true do
      parameter :id, 'account token record id', required: true, type: :integer
      parameter :project_id, 'project id', required: true, type: :integer
    end

    context '200' do
      let!(:id) { account_token_record.id }
      let!(:project_id) { project.id }

      example 'DELETE' do
        explanation 'Delete the account token record and returns an array of present account token records (See GET for response details)'

        request = build(:api_signed_request, '', api_v1_project_account_token_record_path(id: account_token_record.id, project_id: project.id), 'DELETE', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end
end
