# Rubocop gives false positives on empty example groups with rspec_api_documentation DSL
# rubocop:disable RSpec/EmptyExampleGroup

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'IV. Transfers' do
  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org') }
  let!(:project) { create(:project, mission: active_whitelabel_mission, token: create(:token, decimal_places: 8)) }
  let!(:transfer_accepted) { create(:transfer, source: :earned, description: 'Award to a team member', amount: 1000, quantity: 2, award_type: project.default_award_type, account: create(:account, managed_mission: active_whitelabel_mission)) }
  let!(:transfer_paid) { create(:transfer, status: :paid, ethereum_transaction_address: '0x7709dbc577122d8db3522872944cefcb97408d5f74105a1fbb1fd3fb51cc496c', award_type: project.default_award_type, account: create(:account, managed_mission: active_whitelabel_mission)) }
  let!(:transfer_cancelled) { create(:transfer, status: :cancelled, ethereum_transaction_error: 'MetaMask Tx Signature: User denied transaction signature.', award_type: project.default_award_type, account: create(:account, managed_mission: active_whitelabel_mission)) }

  explanation 'Create and cancel transfers, retrieve transfer data.'

  get '/api/v1/projects/:project_id/transfers' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:page) { 1 }

      example_request 'INDEX' do
        explanation 'Returns an array of transfers. See GET for response fields description.'

        expect(status).to eq(200)
      end
    end
  end

  get '/api/v1/projects/:project_id/transfers/:id' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :id, 'transfer id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :id, 'transfer id', type: :integer
      response_field :source, 'transfer source (earned bought mint burn)', type: :string
      response_field :amount, 'transfer amount', type: :string
      response_field :quantity, 'transfer quantity', type: :string
      response_field :totalAmount, 'transfer total amount', type: :string
      response_field :description, 'transfer description', type: :string
      response_field :accountId, 'transfer account id', type: :string
      response_field :ethereumTransactionAddress, 'transfer ethereum transaction address', type: :string
      response_field :ethereumTransactionError, 'latest recieved transaction error (returned from DApp on unsuccessful transaction)', type: :string
      response_field :status, 'transfer status (accepted paid cancelled)', type: :string
      response_field :createdAt, 'transfer creation timestamp', type: :string
      response_field :updatedAt, 'transfer update timestamp', type: :string
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:id) { transfer_paid.id }

      example_request 'GET' do
        explanation 'Returns data for a single transfer.'

        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/projects/:project_id/transfers' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    with_options scope: :transfer, with_example: true do
      parameter :source, 'transfer source ( earned bought mint burn ), defaults to earned', type: :string
      parameter :amount, 'transfer amount (same decimals as token)', required: true, type: :string
      parameter :quantity, 'transfer quantity (2 decimals)', required: true, type: :string
      parameter :total_amount, 'transfer total_amount (amount times quantity, same decimals as token)', required: true, type: :string
      parameter :account_id, 'transfer account id', required: true, type: :string
      parameter :description, 'transfer description', type: :string
    end

    context '302' do
      let!(:project_id) { project.id }

      let!(:source) { 'bought' }
      let!(:amount) { '1000.00000000' }
      let!(:quantity) { '2.00' }
      let!(:total_amount) { '2000.00000000' }
      let!(:account_id) { create(:account, managed_mission: active_whitelabel_mission).managed_account_id }
      let!(:description) { 'investor' }

      example_request 'CREATE' do
        explanation 'Redirects to created transfer'

        expect(status).to eq(302)
      end
    end

    context '400' do
      let!(:project_id) { project.id }

      let!(:amount) { '1000.00' }
      let!(:quantity) { '2' }
      let!(:total_amount) { '2000.0001' }
      let!(:account_id) { create(:account, managed_mission: active_whitelabel_mission).managed_account_id }

      example_request 'CREATE – ERROR' do
        explanation 'Returns an array of errors'

        expect(status).to eq(400)
      end
    end
  end

  delete '/api/v1/projects/:project_id/transfers/:id' do
    with_options with_example: true do
      parameter :id, 'transfer id', required: true, type: :integer
      parameter :project_id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    context '302' do
      let!(:id) { transfer_accepted.id }
      let!(:project_id) { project.id }

      example_request 'CANCEL' do
        explanation 'Redirects to cancelled transfer'

        expect(status).to eq(302)
      end
    end

    context '400' do
      let!(:id) { transfer_paid.id }
      let!(:project_id) { project.id }

      example_request 'CANCEL – ERROR' do
        explanation 'Returns an array of errors'

        expect(status).to eq(400)
      end
    end
  end
end
