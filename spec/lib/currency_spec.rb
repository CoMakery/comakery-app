require 'rails_helper'

describe Comakery::Slack do
  it 'should have matching denomination and precision' do
    expect(Comakery::Currency::DENOMINATIONS.keys.sort).to eq(Comakery::Currency::PRECISION.keys.sort)
  end

  it 'should have matching denomination and precision' do
    expect(Comakery::Currency::DENOMINATIONS.keys.sort).to eq(Comakery::Currency::PER_SHARE_PRECISION.keys.sort)
  end

  it 'should match project denominations' do
    project_denominations = Project.denominations.map {|x,_| x}.sort
    expect(Comakery::Currency::DENOMINATIONS.keys.sort).to eq(project_denominations)
  end
end