require 'rails_helper'
require 'models/blockchain_spec'

describe Blockchain::EthereumRinkeby do
  it_behaves_like 'a blockchain'
end
