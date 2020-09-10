module Blockchain
  module ComakerySecurityToken
    class SyncJob < ApplicationJob
      queue_as :default

      def perform(record)
        @record = record
        @token = record.is_a?(Token) ? record : record.token

        raise 'Token is not Comakery Type' unless @token._token_type_comakery_security_token?

        @contract = Comakery::Web3.new(@token.blockchain.explorer_api_host).contract(@token.contract_address, @token.abi)

        save if sync
      end

      def sync; end

      def save
        @record.synced_at = Time.zone.now
        @record.save!
      end
    end
  end
end
