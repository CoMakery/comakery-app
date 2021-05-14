require 'rails_helper'

describe Comakery::Eth::Tx::Erc20::SecurityToken::SetAllowGroupTransfer, vcr: true do
  let!(:security_token_set_allow_group_transfer) { build(:security_token_set_allow_group_transfer) }

  describe '#method_name' do
    subject { security_token_set_allow_group_transfer.method_name }

    it { is_expected.to eq('setAllowGroupTransfer') }
  end

  describe '#method_params' do
    subject { security_token_set_allow_group_transfer.method_params }

    it do
      is_expected.to eq([
                          security_token_set_allow_group_transfer.blockchain_transaction.blockchain_transactable.sending_group.blockchain_id,
                          security_token_set_allow_group_transfer.blockchain_transaction.blockchain_transactable.receiving_group.blockchain_id,
                          security_token_set_allow_group_transfer.blockchain_transaction.blockchain_transactable.lockup_until.to_i
                        ])
    end
  end
end
