# Rubocop gives false positives on empty example groups with rspec_api_documentation DSL
# rubocop:disable RSpec/EmptyExampleGroup

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'I. General' do
  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org') }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: create(:comakery_token)) }

  explanation 'Details on caching, throttling, inflection and pagination.'

  get '/api/v1/projects' do
    header 'If-Modified-Since', :if_modified

    context '304' do
      let!(:if_modified) { project.updated_at.httpdate }

      example_request 'CACHING' do
        explanation 'Responses include weak `ETag` and `Last-Modified` headers. Server will return HTTP 304 when applicable if request includes valid `If-Modified-Since` header.'

        expect(status).to eq(304)
      end
    end
  end

  get '/api/v1/projects' do
    context '429' do
      before do
        Rails.cache.write("rack::attack:#{Time.now.to_i / 60}:api/ip:127.0.0.1", 1001)
      end

      after do
        Rails.cache.clear
      end

      example_request 'THROTTLING' do
        explanation 'Requests are throttled to 1000rpm per origin to avoid service interruption. On exceeding the limit server will return HTTP 429.'

        expect(status).to eq(429)
      end
    end
  end

  get '/api/v1/projects' do
    header 'Key-Inflection', :key_inflection

    context '200' do
      let!(:key_inflection) { 'dash' }

      example_request 'INFLECTION' do
        explanation 'Inflection is managed via `Key-Inflection` request header with values of `camel`, `dash`, `snake` or `pascal`. By default requests use snake case, responses use camel case.'

        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects' do
    with_options with_example: true do
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:page) { 1 }

      example_request 'PAGINATION' do
        explanation 'Pagination is implemented according RFC-8288 (`Page` request parameter; `Link`, `Total`, `Per-Page` response headers).'

        expect(status).to eq(200)
      end
    end
  end
end
