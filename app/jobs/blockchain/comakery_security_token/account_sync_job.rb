module Blockchain
  module ComakerySecurityToken
    class AccountSyncJob < Blockchain::ComakerySecurityToken::SyncJob
      def sync
        @address = @record.account.ethereum_wallet

        raise 'Wallet is not present' unless @address

        @record.reg_group = @token.reg_groups.find_or_create_by(blockchain_id: @contract.getTransferGroup(@address))
        @record.account_frozen = @contract.getFrozenStatus(@address)
        @record.max_balance = @contract.getMaxBalance(@address)
        @record.lockup_until = Time.zone.at(@contract.getLockUntil(@address))
      end
    end
  end
end
