require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'IV. Transfers' do
  include Rails.application.routes.url_helpers

  before do
    Timecop.freeze(Time.zone.local(2021, 4, 6, 10, 5, 0))
    allow_any_instance_of(Comakery::APISignature).to receive(:nonce).and_return('0242d70898bcf3fbb5fa334d1d87804f')
  end

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }
  let!(:account) { create(:static_account, id: 11111111, managed_mission: active_whitelabel_mission) }
  let!(:project) { create(:static_project, id: 11111112, mission: active_whitelabel_mission, token: create(:static_token, id: 11111113, decimal_places: 8, _blockchain: :ethereum)) }
  let!(:transfer_accepted) { create(:transfer, id: 11111114, description: 'Award to a team member', amount: 1000, quantity: 2, award_type: project.default_award_type, transfer_type: create(:transfer_type, id: 11111115, project: project), account: account) }
  let!(:transfer_paid) { create(:transfer, id: 11111116, status: :paid, ethereum_transaction_address: '0x7709dbc577122d8db3522872944cefcb97408d5f74105a1fbb1fd3fb51cc496c', award_type: project.default_award_type, transfer_type: create(:transfer_type, id: 11111117, project: project), account: account) }
  let!(:transfer_cancelled) { create(:transfer, id: 11111118, status: :cancelled, transaction_error: 'MetaMask Tx Signature: User denied transaction signature.', award_type: project.default_award_type, transfer_type: create(:transfer_type, id: 11111119, project: project), account: account) }

  explanation 'Create and cancel transfers, retrieve transfer data.'

  header 'API-Key', build(:api_key)
  header 'Content-Type', 'application/json'

  get '/api/v1/projects/:project_id/transfers' do
    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
      parameter :page, 'page number', type: :integer
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:page) { 1 }

      example 'INDEX' do
        explanation 'Returns an array of transfers. See GET for response fields description.'

        request = build(:api_signed_request, '', api_v1_project_transfers_path(project_id: project.id), 'GET', 'example.org')
        do_request(request)
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
      response_field :amount, 'transfer amount', type: :string
      response_field :quantity, 'transfer quantity', type: :string
      response_field :totalAmount, 'transfer total amount', type: :string
      response_field :description, 'transfer description', type: :string
      response_field :accountId, 'transfer account id', type: :string
      response_field :transferTypeId, 'category id', type: :string
      response_field :lockupScheduleId, 'lockup schedule id', type: :string
      response_field :commencementDate, 'date of commencement for a lockup period', type: :string
      response_field :transactionError, 'latest recieved transaction error (returned from DApp on unsuccessful transaction)', type: :string
      response_field :status, 'transfer status (accepted paid cancelled)', type: :string
      response_field :recipientWalletId, 'recipient wallet id', type: :string
      response_field :createdAt, 'transfer creation timestamp', type: :string
      response_field :updatedAt, 'transfer update timestamp', type: :string
    end

    context '200' do
      let!(:project_id) { project.id }
      let!(:id) { transfer_paid.id }

      example 'GET' do
        explanation 'Returns data for a single transfer.'

        request = build(:api_signed_request, '', api_v1_project_transfer_path(id: transfer_paid.id, project_id: project.id), 'GET', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end
  end

  post '/api/v1/projects/:project_id/transfers' do
    let(:account) { create(:static_account, id: 11111120, managed_mission: active_whitelabel_mission) }
    let!(:wallet) { create(:wallet, id: 11111121, account: account, _blockchain: project.token._blockchain, address: build(:ethereum_address_1)) }

    with_options with_example: true do
      parameter :project_id, 'project id', required: true, type: :integer
    end

    with_options with_example: true do
      response_field :errors, 'array of errors'
    end

    with_options scope: :transfer, with_example: true do
      parameter :amount, 'transfer amount (same decimals as token)', required: true, type: :string
      parameter :quantity, 'transfer quantity (2 decimals)', required: true, type: :string
      parameter :total_amount, 'transfer total_amount (amount times quantity, same decimals as token)', required: true, type: :string
      parameter :account_id, 'transfer account id', required: true, type: :string
      parameter :transfer_type_id, 'custom transfer type id (default: earned)', required: false, type: :string
      parameter :recipient_wallet_id, 'custom recipient wallet id', required: false, type: :string
      parameter :description, 'transfer description', type: :string
      parameter :lockup_schedule_id, 'custom lockup schedule id for (default: null). Required for Lockup contract only', required: false, type: :string
      parameter :commencement_date, 'date of commencement for a lockup period (default: null). Required for Lockup contract only', required: false, type: :string
    end

    context '201' do
      let!(:project_id) { project.id }

      let!(:transfer) do
        {
          amount: '1000.00000000',
          quantity: '2.00',
          total_amount: '2000.00000000',
          description: 'investor',
          transfer_type_id: create(:transfer_type, id: 11111122, project: project).id.to_s,
          account_id: account.managed_account_id.to_s,
          recipient_wallet_id: wallet.id.to_s
        }
      end

      example 'CREATE' do
        explanation 'Returns created transfer details (See GET for response details)'
        allow_any_instance_of(Award).to receive(:id).and_return('10')

        request = build(:api_signed_request, { transfer: transfer }, api_v1_project_transfers_path(project_id: project.id), 'POST', 'example.org')
        do_request(request)
        expect(status).to eq(201)
      end
    end

    context '400' do
      let!(:project_id) { project.id }

      let!(:transfer) do
        {
          amount: '-1.00',
          account_id: create(:static_account, id: 11111123, email: 'me+cc4b6d00041711cbbb357ebadd3a0560718bb@example.com', managed_account_id: '1c182a7b-4f22-4636-9047-8bab99352949', nickname: 'hunter-0cc45156d229f0a44c939dedb8c1e0ca1de', managed_mission: active_whitelabel_mission).managed_account_id.to_s
        }
      end

      example 'CREATE – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, { transfer: transfer }, api_v1_project_transfers_path(project_id: project.id), 'POST', 'example.org')
        do_request(request)
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

    context '200' do
      let!(:id) { transfer_accepted.id }
      let!(:project_id) { project.id }

      example 'CANCEL' do
        explanation 'Returns cancelled transfer details (See GET for response details)'

        request = build(:api_signed_request, '', api_v1_project_transfer_path(id: transfer_accepted.id, project_id: project.id), 'DELETE', 'example.org')
        do_request(request)
        expect(status).to eq(200)
      end
    end

    context '400' do
      let!(:id) { transfer_paid.id }
      let!(:project_id) { project.id }

      example 'CANCEL – ERROR' do
        explanation 'Returns an array of errors'

        request = build(:api_signed_request, '', api_v1_project_transfer_path(id: transfer_paid.id, project_id: project.id), 'DELETE', 'example.org')
        do_request(request)
        expect(status).to eq(400)
      end
    end
  end
end
