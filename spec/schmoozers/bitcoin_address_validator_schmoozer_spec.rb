require 'rails_helper'

describe BitcoinAddressValidatorSchmoozer do
  load 'app/schmoozers/bitcoin_address_validator_schmoozer.rb'
  let(:address) { 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps' }
  let(:validator) { described_class.new(__dir__) }

  it 'bitcoin address is valid' do
    expect(validator.is_valid_bitcoin_address(address)).to eq true
  end

  it 'bitcoin address is invalid' do
    expect(validator.is_valid_bitcoin_address("#{address}123")).to eq false
  end
end
