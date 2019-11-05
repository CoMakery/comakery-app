module Blockchain
  module ComakerySecurityToken
    class SyncJob < ApplicationJob
      queue_as :default

      def perform(record)
        @record = record
        @token = record.is_a?(Token) ? record : record.token

        raise 'Token is not Comakery Type' unless @token.coin_type_comakery?

        @contract = Comakery::Web3.new(@token.ethereum_network).contract(@token.ethereum_contract_address, @token.abi)

        sync
        save
      end

      def sync; end

      def save
        @record.synced_at = Time.zone.now
        @record.save!
      end
    end
  end
end
