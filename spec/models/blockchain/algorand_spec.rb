require 'rails_helper'
require 'models/blockchain_spec'

describe Blockchain::Algorand do
  it_behaves_like 'a blockchain'

  specify { expect(described_class.new.name).to eq('Algorand') }
  specify { expect(described_class.new.explorer_api_host).to eq('api.algoexplorer.io/idx2') }
  specify { expect(described_class.new.explorer_human_host).to eq('algoexplorer.io') }
  specify { expect(described_class.new.mainnet?).to be_truthy }
  specify { expect(described_class.new.number_of_confirmations).to eq(1) }
  specify { expect(described_class.new.sync_period).to eq(60) }
  specify { expect(described_class.new.sync_max).to eq(10) }
  specify { expect(described_class.new.sync_waiting).to eq(600) }
  specify { expect(described_class.new.url_for_tx_human('null')).to eq('https://algoexplorer.io/tx/null') }
  specify { expect(described_class.new.url_for_tx_api('null')).to eq('https://api.algoexplorer.io/idx2/v2/transactions?txid=null') }
  specify { expect(described_class.new.url_for_address_human('null')).to eq('https://algoexplorer.io/address/null') }
  specify { expect(described_class.new.url_for_address_api('null')).to eq('https://api.algoexplorer.io/idx2/v2/accounts/null') }
  specify { expect(described_class.new.url_for_app_api('null')).to eq('https://api.algoexplorer.io/idx2/v2/applications/null') }
  specify { expect(described_class.new.supported_by_ore_id?).to be_truthy }
  specify { expect(described_class.new.ore_id_name).to eq('algo_main') }

  describe '#account_coin_balance' do
    specify do
      expect_any_instance_of(Comakery::Algorand).to receive(:account_balance).with('dummy_addr')
      described_class.new.account_coin_balance('dummy_addr')
    end
  end
end
