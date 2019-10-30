module Blockchain
  class SyncJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      comakery_security_tokens
    end

    private

      def comakery_security_tokens
        Token.coin_type_comakery.each do |token|
          Blockchain::ComakerySecurityToken::TokenSyncJob.perform_later(token)
        end
      end
  end
end
