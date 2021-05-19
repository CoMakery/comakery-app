require 'rails_helper'

RSpec.describe TransfersExporter do
  before do
    Timecop.freeze(Time.zone.local(2021, 4, 6, 10, 5, 0))
  end

  after do
    Timecop.return
  end

  let(:project) { create(:project, token: create(:static_token)) }

  let!(:active_whitelabel_mission) { create(:mission, whitelabel: true, whitelabel_domain: 'example.org', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)) }

  let!(:account) { create(:static_account, id: 41, managed_mission: active_whitelabel_mission) }

  let!(:transfer) { create(:transfer, id: 51, status: :paid, ethereum_transaction_address: '0x7709dbc577122d8db3522872944cefcb97408d5f74105a1fbb1fd3fb51cc496c', award_type: project.default_award_type, transfer_type: create(:transfer_type, id: 47, name: 'Type fb3c15da8f', project: project), account: account) }

  subject(:object) { described_class.new(project) }

  describe '#transfers_csv_columns' do
    it 'returns the columns for transfers CSV' do
      expect(object.transfers_csv_columns).to match_array ['Recipient User ID', 'Recipient First Name', 'Recipient Last Name', 'Recipient blockchain adddress', 'Sender First Name', 'Sender Last Name', 'Sender blockchain adddress', 'Transfer Name', 'Transfer Type', 'Amount(TKN7b9d835bc7eab2acde5e892b447cd2b83b6788fd)', 'Quantity', 'Total(TKN7b9d835bc7eab2acde5e892b447cd2b83b6788fd)', 'Transaction ID', 'Transfered', 'Created At']
    end
  end

  describe '#transfers_csv_row' do
    it 'generate row for transfers CSV' do
      expect(object.transfers_csv_row(transfer.decorate)).to match_array [41, 'Eva', 'Smith', nil, 'Eva', 'Smith', nil, 'Bought', 'Type fb3c15da8f', '50.00000000', 0.1e1, '50.00000000', '0x7709dbc5...', 'Apr  6 2021', 'Apr  6 2021']
    end
  end

  describe '#generate_transfers_csv' do
    it 'generate the data for transfer CSV' do
      expect(object.generate_transfers_csv).to eq "\"Recipient User ID\",\"Recipient First Name\",\"Recipient Last Name\",\"Recipient blockchain adddress\",\"Sender First Name\",\"Sender Last Name\",\"Sender blockchain adddress\",\"Transfer Name\",\"Transfer Type\",\"Amount(TKN7b9d835bc7eab2acde5e892b447cd2b83b6788fd)\",\"Quantity\",\"Total(TKN7b9d835bc7eab2acde5e892b447cd2b83b6788fd)\",\"Transaction ID\",\"Transfered\",\"Created At\"\n\"41\",\"Eva\",\"Smith\",\"\",\"Eva\",\"Smith\",\"\",\"Bought\",\"Type fb3c15da8f\",\"50.00000000\",\"1.0\",\"50.00000000\",\"0x7709dbc5...\",\"Apr  6 2021\",\"Apr  6 2021\"\n"
    end
  end
end
