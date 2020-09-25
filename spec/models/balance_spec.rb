require 'rails_helper'

describe Balance, type: :model do
  subject { create(:balance) }
  it { is_expected.to belong_to(:wallet) }
  it { is_expected.to belong_to(:token) }
  it { is_expected.to validate_presence_of(:base_unit_value) }
  it { is_expected.to validate_numericality_of(:base_unit_value).only_integer.is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_uniqueness_of(:wallet_id).scoped_to(:token_id) }

  describe '#value' do
    let(:balance) { create(:balance) }

    specify do
      expect(balance.token).to receive(:from_base_unit).with(balance.base_unit_value)
      balance.value
    end
  end
end
