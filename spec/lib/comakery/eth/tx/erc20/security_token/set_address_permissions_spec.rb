require 'rails_helper'

describe Comakery::Eth::Tx::Erc20::SecurityToken::SetAddressPermissions, vcr: true do
  let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

  describe '#method_name' do
    subject { security_token_set_address_permissions.method_name }

    it { is_expected.to eq('setAddressPermissions') }
  end

  describe '#method_params' do
    subject { security_token_set_address_permissions.method_params }

    it do
      is_expected.to eq([
                          security_token_set_address_permissions.blockchain_transaction.destination,
                          security_token_set_address_permissions.blockchain_transaction.blockchain_transactable.reg_group.blockchain_id,
                          security_token_set_address_permissions.blockchain_transaction.blockchain_transactable.lockup_until.to_i,
                          security_token_set_address_permissions.blockchain_transaction.blockchain_transactable.max_balance,
                          security_token_set_address_permissions.blockchain_transaction.blockchain_transactable.account_frozen
                        ])
    end
  end
end
