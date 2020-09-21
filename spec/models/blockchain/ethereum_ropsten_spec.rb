require 'rails_helper'
require 'models/blockchain_spec'

describe Blockchain::EthereumRopsten do
  it_behaves_like 'a blockchain'

  specify { expect(described_class.new.name).to eq('EthereumRopsten') }
  specify { expect(described_class.new.explorer_human_host).to eq('ropsten.etherscan.io') }
  specify { expect(described_class.new.explorer_api_host).to eq('ropsten.infura.io') }
  specify { expect(described_class.new.mainnet?).to be_falsey }
end
