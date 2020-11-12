require 'rails_helper'
require 'models/blockchain_spec'

describe Blockchain::AlgorandBeta do
  it_behaves_like 'a blockchain'

  specify { expect(described_class.new.name).to eq('AlgorandBeta') }
  specify { expect(described_class.new.explorer_api_host).to eq('api.betanet.algoexplorer.io/idx2') }
  specify { expect(described_class.new.explorer_human_host).to eq('betanet.algoexplorer.io') }
  specify { expect(described_class.new.mainnet?).to be_falsey }
  specify { expect(described_class.new.url_for_tx_human('null')).to eq('https://betanet.algoexplorer.io/tx/null') }
  specify { expect(described_class.new.url_for_tx_api('null')).to eq('https://api.betanet.algoexplorer.io/idx2/v2/transactions?txid=null') }
  specify { expect(described_class.new.url_for_address_human('null')).to eq('https://betanet.algoexplorer.io/address/null') }
  specify { expect(described_class.new.url_for_address_api('null')).to eq('https://api.betanet.algoexplorer.io/idx2/v2/accounts/null') }
  specify { expect(described_class.new.ore_id_name).to eq('algo_beta') }
end
