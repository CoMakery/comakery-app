require 'rails_helper'
require 'models/blockchain_spec'

describe Blockchain::EosTest do
  it_behaves_like 'a blockchain'

  specify { expect(described_class.new.name).to eq('EosTest') }
  specify { expect(described_class.new.explorer_human_host).to eq('jungle.bloks.io') }
  specify { expect(described_class.new.mainnet?).to be_falsey }
end
