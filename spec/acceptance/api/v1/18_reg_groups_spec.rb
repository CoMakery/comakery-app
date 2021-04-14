require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'VIII. Reg Groups' do
  include Rails.application.routes.url_helpers
    before do
    Timecop.freeze(Time.local(2021, 4, 6, 10, 5, 0))
    allow_any_instance_of(Comakery::APISignature).to receive(:nonce).and_return('0242d70898bcf3fbb5fa334d1d87804f')
  end

  after do
    Timecop.return
  end

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:reg_group) { create(:reg_group, id: 30, name: 'RegGroup 18ba883fac1e9b8e3f400bf3cf718c5ea33daf27', blockchain_id: 1001, token: create(:comakery_dummy_token, id: 25)) }
  let!(:project) { create(:project, id: 50, mission: active_whitelabel_mission, token: reg_group.token) }

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
        project.token.reg_groups.where.not(id: 30).last.update(id: 31)
        explanation 'Returns an array of reg groups. See GET for response fields description.'

        request = build(:api_signed_request, '', api_v1_project_reg_groups_path(project_id: project.id), 'GET', 'example.org')
        result = do_request(request)          
        result[0][:response_headers]['ETag'] = 'W/"194440b6abad010a97cbd1803dfbda57"' if status == 200
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
        result = do_request(request)
        result[0][:response_headers]['ETag'] = 'W/"e33792454459bbb88af041dd5505e841"' if status == 200
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
      parameter :blockchain_id, 'reg group id on blockchain (will be auto-generated if not provided)', type: :string
    end

    context '201' do
      let!(:project_id) { project.id }

      let!(:valid_attributes) do
        { name: 'Test' }
      end

      example 'CREATE' do
        explanation 'Returns created reg group details (See GET for response details)'
        request = build(:api_signed_request, { reg_group: valid_attributes }, api_v1_project_reg_groups_path(project_id: project.id), 'POST', 'example.org')
        result = do_request(request)
        if status == 201
          body = JSON.parse(result[0][:response_body])
          body['id'] = 45
          result[0][:response_body] = body.to_json
          result[0][:response_headers]['ETag'] = 'W/"91c1cb4658d2313c0c5b589a9c86cace"'
        end
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
        result = do_request(request)
        result[0][:response_headers]['ETag'] = 'W/"4f53cda18c2baa0c0354bb5f9a3ecbe5"' if status == 200
        expect(status).to eq(200)
      end
    end
  end
end
