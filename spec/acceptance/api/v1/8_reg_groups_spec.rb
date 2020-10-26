require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'VIII. Reg Groups' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:reg_group) { create(:reg_group) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: reg_group.token) }

  explanation 'Create and delete reg groups, retrieve reg group data.'

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/projects/:project_id/reg_groups' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:page) { 1 }

      example 'INDEX' do
        explanation 'Returns an array of reg groups. See GET for response fields description.'

        request = build(:api_signed_request, '', api_v1_project_reg_groups_path(project_id: project.id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects/:project_id/reg_groups/:id' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :id, 'reg group id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :id, 'reg group id', type: :integer
      response_field :name, 'reg group name', type: :integer
      response_field :blockchain_id, 'reg group id on blockchain', type: :integer
      response_field :token_id, 'reg group token id', type: :integer
      response_field :createdAt, 'creation timestamp', type: :string
      response_field :updatedAt, 'update timestamp', type: :string
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:id) { reg_group.id }

      example 'GET' do
        explanation 'Returns data for a single reg group.'

        request = build(:api_signed_request, '', api_v1_project_reg_group_path(id: reg_group.id, project_id: project.id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/projects/:project_id/reg_groups' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    with_options scope: :reg_group, with_example: true do
      parameter :name, 'reg group name', required: true, type: :string
      parameter :blockchain_id, 'reg group id on blockchain', type: :string
    end

    context '201' do
      let!(:project_id) { project.id }

      let!(:valid_attributes) do
        { name: 'Test' }
      end

      example 'CREATE' do
        explanation 'Returns created reg group details (See GET for response details)'

        request = build(:api_signed_request, { reg_group: valid_attributes }, api_v1_project_reg_groups_path(project_id: project.id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:project_id) { project.id }

      let!(:invalid_attributes) do
        {
          blockchain_id: '-15'
        }
      end

      example 'CREATE – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { reg_group: invalid_attributes }, api_v1_project_reg_groups_path(project_id: project.id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/projects/:project_id/reg_groups/:id' do
    with_options with_example: true do
      parameter :id, 'reg group id', required: true, type: :integer
      parameter :project_id, 'project id', required: true, type: :integer
    end

    context '200' do
      let!(:id) { reg_group.id }
      let!(:project_id) { project.id }

      example 'DELETE' do
        explanation 'Delete the reg group and returns an array of present reg groups (See GET for response details)'

        request = build(:api_signed_request, '', api_v1_project_reg_group_path(id: reg_group.id, project_id: project.id), 'DELETE', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end
end
