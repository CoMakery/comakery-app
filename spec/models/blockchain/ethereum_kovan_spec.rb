require 'rails_helper'
require 'models/blockchain_spec'

describe Blockchain::EthereumKovan do
  it_behaves_like 'a blockchain'
end
