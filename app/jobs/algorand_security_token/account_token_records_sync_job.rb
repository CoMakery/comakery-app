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

        balance = Balance.find_or_initialize_by(
          token: token,
          wallet: opt_in.wallet
        )

        balance.base_unit_value = state['balance']
        balance.save!
      end
    end

    private

      def opt_ins
        @opt_ins ||= TokenOptIn.opted_in.where(
          token: token
        )
      end

      def app
        @app ||= Comakery::Algorand.new(token.blockchain, nil, token.contract_address)
      end

      def local_state(addr)
        app.account_local_state_decoded(addr)
      end
  end
end
