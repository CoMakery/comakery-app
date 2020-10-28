module BlockchainJob
  module ComakerySecurityTokenJob
    class TransferRulesSyncJob < ApplicationJob
      ALLOW_GROUP_TRANSFER_HASH = '0x5845e315015ee03f0d4ab1d198172b4f733609dc3de8b957ae1d86c874030189'.freeze

      def perform(token)
        @token = token
        raise 'Token is not Comakery Type' unless @token._token_type_comakery_security_token?

        @decoder = Ethereum::Decoder.new
        @transfer_rules = []
        @reg_groups = @token.reg_groups.to_a

        @client = Comakery::Eth.new(@token.blockchain.explorer_api_host).client

        filtered_events.each { |event| process_event(event) }
        @transfer_rules.each(&:save!)
      end

      def filtered_events
        @client.eth_get_logs(
          address: @token.contract_address,
          topics: [ALLOW_GROUP_TRANSFER_HASH],
          fromBlock: 'earliest',
          toBlock: 'latest'
        ).fetch('result')
      end

      def process_event(event_data)
        # removed: true when the log was removed, due to a chain reorganization. false if it's a valid log.
        return if event_data['removed']
        # transactionHash: 32 Bytes - hash of the transactions this log was created from. null when its pending log.
        return unless event_data['transactionHash']

        lockup_until = @decoder.decode('uint256', event_data['data'])
        return if lockup_until.zero?

        topics = event_data.fetch('topics')
        blockchain_from_group_id = @decoder.decode('uint256', topics[2])
        blockchain_to_group_id = @decoder.decode('uint256', topics[3])
        build_transfer_rule(blockchain_from_group_id, blockchain_to_group_id, lockup_until)
      end

      def build_transfer_rule(blockchain_from_group_id, blockchain_to_group_id, lockup_until)
        sending_group = reg_group(blockchain_from_group_id)
        receiving_group = reg_group(blockchain_to_group_id)

        transfer_rule =
          if (index = find_index_of_group_in_built_transfer_rules(sending_group, receiving_group))
            @transfer_rules[index]
          else
            @transfer_rules << TransferRule.new(sending_group_id: sending_group.id, receiving_group_id: receiving_group.id, token_id: @token.id)
            @transfer_rules.last
          end

        transfer_rule.lockup_until = lockup_until
        transfer_rule.status = 'synced'
        transfer_rule.synced_at = Time.zone.now
        transfer_rule
      end

      def find_index_of_group_in_built_transfer_rules(sending_group, receiving_group)
        @transfer_rules.find_index do |tr|
          tr.sending_group_id == sending_group.id && tr.receiving_group_id == receiving_group.id && tr.token_id == @token.id
        end
      end

      def reg_group(blockchain_group_id)
        cached_group =
          @reg_groups.find do |reg_group|
            reg_group.blockchain_id == blockchain_group_id && reg_group.token_id == @token.id
          end

        if cached_group
          @reg_groups << cached_group
          cached_group
        else
          @reg_groups << RegGroup.find_or_create_by!(token_id: @token.id, blockchain_id: blockchain_group_id)
          @reg_groups.last
        end
      end
    end
  end
end
