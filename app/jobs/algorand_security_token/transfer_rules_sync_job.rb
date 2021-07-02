module AlgorandSecurityToken
  class TransferRulesSyncJob < ApplicationJob
    queue_as :default

    attr_reader :token

    def perform(token)
      @token = token

      rules.each do |k, lockup_until|
        groups = key_to_reg_groups(k)

        TransferRule.create!(
          token: token,
          lockup_until: lockup_until,
          sending_group: groups[0],
          receiving_group: groups[1],
          status: :synced,
          synced_at: Time.current
        )
      end
    end

    private

      def app
        @app ||= Comakery::Algorand.new(token.blockchain, nil, token.contract_address)
      end

      def rules
        @rules ||= app.app_global_state_decoded.select { |k, _v| k.include? 'rule' }
      end

      def key_to_reg_groups(key)
        groups = key.split('rule').last
        from_id = groups.first(8).reverse.unpack1('Q')
        to_id = groups.last(8).reverse.unpack1('Q')

        [
          RegGroup.find_or_create_by!(token: token, blockchain_id: from_id),
          RegGroup.find_or_create_by!(token: token, blockchain_id: to_id)
        ]
      end
  end
end
