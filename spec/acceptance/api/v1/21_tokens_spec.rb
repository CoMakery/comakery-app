require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'X. Tokens' do
  include Rails.application.routes.url_helpers

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:account, managed_mission: active_whitelabel_mission) }

  explanation ['Retrieve data tokens.'   \
          'Note 1: Filtering with fields named with capital letter ex: contractAddress should be contract_address.'
              ].join(' ')

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/tokens' do
    with_options with_example: true do
      response_field :id, 'id', type: :integer
      response_field :name, 'name', type: :string
      response_field :symbol, 'symbol', type: :string
      response_field :network, 'network', type: :string
      response_field :contractAddress, 'contact address', type: :string
      response_field :decimalPlaces, 'decimal places', type: :string
      response_field :imageUrl, 'image url', type: :string
      response_field :createdAt, 'token creation timestamp', type: :string
      response_field :updatedAt, 'token update timestamp', type: :string
    end

    context '200' do
      let!(:cat_token) { create(:token, name: 'Cats') }

      example 'GET' do
        explanation 'Returns tokens'

        request = build(:api_signed_request, '', api_v1_tokens_path, 'GET', 'example.org')

        do_request(request)
        expect(status).to eq(200)
      end
    end

    context '400' do
      let!(:cat_token) { create(:token, name: 'Cats') }

      example 'INDEX – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, '', api_v1_tokens_path, 'GET', 'example.org')
        request[:q] = { _blockchain_cont: 'bitcoin'}

        do_request(request)
        expect(status).to eq(400)
      end
    end
  end
end
