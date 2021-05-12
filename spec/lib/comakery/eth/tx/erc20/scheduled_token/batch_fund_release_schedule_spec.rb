require 'rails_helper'

describe Comakery::Eth::Tx::Erc20::ScheduledToken::BatchFundReleaseSchedule, vcr: true do
  let!(:lockup_batch_transfer) { build(:lockup_batch_transfer) }

  describe '#method_name' do
    subject { lockup_batch_transfer.method_name }

    it { is_expected.to eq('batchFundReleaseSchedule') }
  end

  describe '#method_params' do
    subject { lockup_batch_transfer.method_params }

    it {
      is_expected.to eq([
                          lockup_batch_transfer.blockchain_transaction.destinations,
                          lockup_batch_transfer.blockchain_transaction.amounts,
                          lockup_batch_transfer.blockchain_transaction.commencement_dates,
                          lockup_batch_transfer.blockchain_transaction.lockup_schedule_ids
                        ])
    }
  end

  describe '#abi' do
    subject { lockup_batch_transfer.abi }

    it { is_expected.to be_an(Array) }
  end

  describe '#valid?' do
    subject { lockup_batch_transfer.valid? }

    it { is_expected.to be_truthy }
  end
end
