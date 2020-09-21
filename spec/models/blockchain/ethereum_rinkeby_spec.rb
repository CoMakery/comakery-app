require 'rails_helper'
require 'models/blockchain_spec'

describe Blockchain::EthereumRinkeby do
  it_behaves_like 'a blockchain'

  specify { expect(described_class.new.name).to eq('EthereumRinkeby') }
  specify { expect(described_class.new.explorer_human_host).to eq('rinkeby.etherscan.io') }
  specify { expect(described_class.new.explorer_api_host).to eq('rinkeby.infura.io') }
  specify { expect(described_class.new.mainnet?).to be_falsey }
end
