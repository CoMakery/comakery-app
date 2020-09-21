require 'rails_helper'
require 'models/blockchain_spec'

describe Blockchain::EthereumKovan do
  it_behaves_like 'a blockchain'

  specify { expect(described_class.new.name).to eq('EthereumKovan') }
  specify { expect(described_class.new.explorer_human_host).to eq('kovan.etherscan.io') }
  specify { expect(described_class.new.explorer_api_host).to eq('kovan.infura.io') }
  specify { expect(described_class.new.mainnet?).to be_falsey }
end
