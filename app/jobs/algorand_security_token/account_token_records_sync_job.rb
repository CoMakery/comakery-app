module AlgorandSecurityToken
  class AccountTokenRecordsSyncJob < ApplicationJob
    queue_as :default

    attr_reader :token

    def perform(token)
      @token = token

      opt_ins.each do |opt_in|
        state = local_state(opt_in.wallet.address)

        AccountTokenRecord.create!(
          token: token,
          wallet: opt_in.wallet,
          account: opt_in.wallet.account,
          lockup_until: state['lockUntil'],
          max_balance: state['maxBalance'],
          reg_group: RegGroup.find_or_create_by!(token: token, blockchain_id: state['transferGroup']),
          account_frozen: state['frozen'] == 1,
          status: :synced,
          synced_at: Time.current
        )

        balance = Balance.find_or_initialize_by(token: token, wallet: opt_in.wallet)
        balance.sync_with_blockchain!
      end
    end

    private

      def opt_ins
        @opt_ins ||= TokenOptIn.opted_in.where(
          token: token
        )
      end

      def local_state(addr)
        token.token_type.contract.account_local_state_decoded(addr)
      end
  end
end
