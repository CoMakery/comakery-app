require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'I. General' do
  include Rails.application.routes.url_helpers

  before do
    Timecop.freeze(Time.local(2021, 4, 6, 10, 5, 0))
  end

  after do
    Timecop.return
  end

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }

  let!(:project) { create(:static_project, id: 20, mission: active_whitelabel_mission, token: create(:static_comakery_token, id: 80)) }

  before do
    allow_any_instance_of(Comakery::APISignature).to receive(:nonce).and_return('0242d70898bcf3fbb5fa334d1d87804f')
    project.transfer_types.each_with_index do |t_type, i|
      t_type.update_column(:id, 905+i)
    end
  end

  explanation 'Details on authentication, caching, throttling, inflection and pagination.'

  header 'API-Key', build(:api_key)

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
        explanation [
          'Requests should include `API-Key` header and a correct proof based on `Ed25519Signature2018` in the format described below.' \
          'All values should be strings.' \
          'Note 1: When calculating the signature, request data should be serialized according JSON Canonicalization Scheme.' \
          'Note 2: Blockchain Transactions (VII) endpoints do not require proof and can be accessed with either `API-Key` or `API-Transaction-Key` header. See section VII for examples.'
        ].join(' ')

        request = build(:api_signed_request, '', api_v1_projects_path, 'GET', 'example.org')
        result = do_request(request)
        
        result[0][:response_headers]['ETag'] = 'ETag: W/"65619e25d426a61fdaaea38f54f63b1f"' if status == 200
        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects' do
    header 'API-Key', '12345'

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
        result = do_request(request)
        result[0][:response_headers]['ETag'] = 'W/"e1ecbd938491cc1765caf2c0ea693a2c"' if status == 304
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
        result = do_request(request)
        result[0][:response_headers]['ETag'] = 'W/"e1ecbd938491cc1765caf2c0ea693a2c"' if status == 200
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
        result = do_request(request)
        result[0][:response_headers]['ETag'] = 'W/"5fa3c6359b49359241b800a7b6135cbe"' if status == 200
        expect(status).to eq(200)
      end
    end
  end
end
