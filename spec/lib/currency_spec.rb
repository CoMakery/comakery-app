require 'rails_helper'

describe Comakery::Currency do
  it 'has matching denomination and precision' do
    expect(Comakery::Currency::DENOMINATIONS.keys.sort).to eq(Comakery::Currency::PRECISION.keys.sort)
  end

  it 'has matching denomination and precision' do
    expect(Comakery::Currency::DENOMINATIONS.keys.sort).to eq(Comakery::Currency::PER_SHARE_PRECISION.keys.sort)
  end

  it 'matches token denominations' do
    token_denominations = Token.denominations.map { |x, _| x }.sort
    expect(Comakery::Currency::DENOMINATIONS.keys.sort).to eq(token_denominations)
  end
end
