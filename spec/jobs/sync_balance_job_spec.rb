require 'rails_helper'

RSpec.describe SyncBalanceJob, type: :job do
  let(:balance) { create(:balance) }
  subject { described_class.perform_now(balance) }

  it 'succesfully update a value' do
    allow_any_instance_of(Balance).to receive(:blockchain_balance_base_unit_value).and_return(999)
    is_expected.to be true
    expect(balance.reload.base_unit_value).to eq 999
  end

  context 'do not update a value' do
    let(:balance) { create(:balance, created_at: 1.day.ago, base_unit_value: 10) }

    it 'when it was updated recently' do
      allow_any_instance_of(Balance).to receive(:blockchain_balance_base_unit_value).and_return(999)
      is_expected.to be nil
      expect(balance.reload.base_unit_value).to eq 10
    end
  end
end
