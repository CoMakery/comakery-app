require 'rails_helper'

describe CardanoAddressValidatorSchmoozer do
  let(:address) { 'Ae2tdPwUPEZ3uaf7wJVf7ces9aPrc6Cjiz5eG3gbbBeY3rBvUjyfKwEaswp' }
  let(:validator) { described_class.new(__dir__) }

  it 'cardano address is valid' do
    expect(validator.is_valid_address(address)).to eq true
  end

  it 'cardano address is invalid' do
    expect(validator.is_valid_address("#{address}123")).to eq false
  end
end
