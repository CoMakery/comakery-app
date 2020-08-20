require 'rails_helper'
require 'models/blockchain_spec'

describe Blockchain::Ethereum do
  it_behaves_like 'a blockchain'
end
