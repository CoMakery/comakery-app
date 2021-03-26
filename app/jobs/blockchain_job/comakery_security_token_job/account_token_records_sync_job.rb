module BlockchainJob
  module ComakerySecurityTokenJob
    class AccountTokenRecordsSyncJob < ApplicationJob
      queue_as :default

      attr_reader :token

      def perform(token)
        @token = token

        wallets.each do |wallet|
          AccountTokenRecord.create!(
            token: token,
            wallet: wallet,
            account: wallet.account,
            lockup_until: contract.call.get_lock_until(wallet.address),
            max_balance: contract.call.get_max_balance(wallet.address),
            reg_group: RegGroup.find_or_create_by!(token: token, blockchain_id: contract.call.get_transfer_group(wallet.address)),
            account_frozen: contract.call.get_frozen_status(wallet.address),
            status: :synced,
            synced_at: Time.current
          )

          balance = Balance.find_or_initialize_by(
            token: token,
            wallet: wallet
          )

          balance.base_unit_value = contract.call.balance_of(wallet.address)
          balance.save!
        end
      end

      private

        def wallets
          Wallet.where(_blockchain: token._blockchain)
        end

        def contract
          @contract ||= token.token_type.contract.contract
        end
    end
  end
end
