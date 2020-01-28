# Rubocop gives false positives on empty example groups with rspec_api_documentation DSL

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'I. General' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key)) }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: create(:comakery_token)) }

  explanation 'Details on authentication, caching, throttling, inflection and pagination.'

  header 'API-Public-Key', build(:api_public_key)

  get '/api/v1/projects' do
    with_options scope: :body, with_example: true do
      parameter :data, 'request data', required: true
      parameter :url, 'request url', required: true
      parameter :method, 'request http method', required: true
      parameter :nonce, 'request nonce (rotated every 24h)', required: true
      parameter :timestamp, 'request timestamp (expires in 60 seconds)', required: true
    end

    with_options scope: :proof, with_example: true do
      parameter :type, 'Ed25519Signature2018', required: true
      parameter :verificationMethod, 'public key', required: true
      parameter :signature, 'request signature', required: true
    end

    context '200' do
      example 'AUTHENTICATION' do
        explanation 'Requests should include `API-Public-Key` header and a correct proof based on `Ed25519Signature2018` in the format described below. All values should be strings. Note: When calculating the signature, request data should be serialized according JSON Canonicalization Scheme.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects' do
    header 'API-Public-Key', '12345'

    context '401' do
      example 'AUTHENTICATION – INCORRECT PUBLIC KEY HEADER' do
        explanation 'Requests with incorrect public key header will be denied.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(401)
      end
    end
  end

  get '/api/v1/projects' do
    context '401' do
      example 'AUTHENTICATION – INCORRECT PROOF' do
        explanation 'Requests with incorrect proof, url, method, timestamp or nonce will be denied.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example1.org')
        do_request(request)
        expect(status).to eq(401)
      end
    end
  end

  get '/api/v1/projects' do
    header 'If-Modified-Since', :if_modified

    context '304' do
      let!(:if_modified) { project.updated_at.httpdate }

      example 'CACHING' do
        explanation 'Responses include weak `ETag` and `Last-Modified` headers. Server will return HTTP 304 when applicable if request includes valid `If-Modified-Since` header.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        do_request(request)
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

      example 'THROTTLING' do
        explanation 'Requests are throttled to 1000rpm per origin to avoid service interruption. On exceeding the limit server will return HTTP 429.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(429)
      end
    end
  end

  get '/api/v1/projects' do
    header 'Key-Inflection', :key_inflection

    context '200' do
      let!(:key_inflection) { 'dash' }

      example 'INFLECTION' do
        explanation 'Inflection is managed via `Key-Inflection` request header with values of `camel`, `dash`, `snake` or `pascal`. By default requests use snake case, responses use camel case.'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        do_request(request)
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

      example 'PAGINATION' do
        explanation 'Pagination is implemented according RFC-8288 (`Page` request parameter; `Link`, `Total`, `Per-Page` response headers).'

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end
end
