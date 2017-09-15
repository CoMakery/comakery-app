require 'rails_helper'

describe Comakery::Currency do
  it 'has matching denomination and precision' do
    expect(Comakery::Currency::DENOMINATIONS.keys.sort).to eq(Comakery::Currency::PRECISION.keys.sort)
  end

  it 'has matching denomination and precision' do
    expect(Comakery::Currency::DENOMINATIONS.keys.sort).to eq(Comakery::Currency::PER_SHARE_PRECISION.keys.sort)
  end

  it 'matches project denominations' do
    project_denominations = Project.denominations.map { |x, _| x }.sort
    expect(Comakery::Currency::DENOMINATIONS.keys.sort).to eq(project_denominations)
  end
end
