require 'rails_helper'
require 'models/blockchain_spec'

describe Blockchain::BitcoinTest do
  it_behaves_like 'a blockchain'

  specify { expect(described_class.new.name).to eq('BitcoinTest') }
  specify { expect(described_class.new.explorer_human_host).to eq('live.blockcypher.com/btc-testnet') }
  specify { expect(described_class.new.mainnet?).to be_falsey }
end
