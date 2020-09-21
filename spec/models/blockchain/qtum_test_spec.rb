require 'rails_helper'
require 'models/blockchain_spec'

describe Blockchain::QtumTest do
  it_behaves_like 'a blockchain'

  specify { expect(described_class.new.name).to eq('QtumTest') }
  specify { expect(described_class.new.explorer_human_host).to eq('testnet.qtum.org') }
  specify { expect(described_class.new.explorer_api_host).to eq('testnet.qtum.info') }
  specify { expect(described_class.new.mainnet?).to be_falsey }
end
