require 'rails_helper'

describe Comakery::Eth::Tx::Erc20::ScheduledToken::FundReleaseSchedule, vcr: true do
  let!(:lockup_transfer) { build(:lockup_transfer) }

  describe '#method_name' do
    subject { lockup_transfer.method_name }

    it { is_expected.to eq('fundReleaseSchedule') }
  end

  describe '#method_params' do
    subject { lockup_transfer.method_params }

    it {
      is_expected.to eq([
                          lockup_transfer.blockchain_transaction.destination,
                          lockup_transfer.blockchain_transaction.amount,
                          lockup_transfer.blockchain_transaction.commencement_dates.first,
                          lockup_transfer.blockchain_transaction.lockup_schedule_ids.first
                        ])
    }
  end

  describe '#abi' do
    subject { lockup_transfer.abi }

    it { is_expected.to be_an(Array) }
  end

  describe '#valid?' do
    subject { lockup_transfer.valid? }

    it { is_expected.to be_truthy }
  end
end
