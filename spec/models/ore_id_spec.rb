require 'rails_helper'

RSpec.describe OreId, type: :model do
  it { is_expected.to belong_to(:account) }
  it { is_expected.to have_one(:wallet).dependent(:destroy) }
end
