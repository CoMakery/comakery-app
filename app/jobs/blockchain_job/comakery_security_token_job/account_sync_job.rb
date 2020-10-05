module BlockchainJob
  module ComakerySecurityTokenJob
    class AccountSyncJob < BlockchainJob::ComakerySecurityTokenJob::SyncJob
      def sync
        @address = @record.account.address_for_blockchain(@token&._blockchain)

        return false unless @address&.present?

        @record.reg_group = @token.reg_groups.find_or_create_by(blockchain_id: @contract.getTransferGroup(@address))
        @record.account_frozen = @contract.getFrozenStatus(@address)
        @record.max_balance = @contract.getMaxBalance(@address)
        @record.balance = @contract.balanceOf(@address)
        @record.lockup_until = Time.zone.at(@contract.getLockUntil(@address))
      end
    end
  end
end
