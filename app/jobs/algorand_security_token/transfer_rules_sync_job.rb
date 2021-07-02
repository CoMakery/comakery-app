module AlgorandSecurityToken
  class TransferRulesSyncJob < ApplicationJob
    queue_as :default

    attr_reader :token

    def perform(token)
      @token = token
      logger = Logger.new("#{Rails.root}/rules")
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')
      logger.info('XXX')

      Sidekiq::Logging.logger('HERE')
      rules.each do |k, lockup_until|
        groups = key_to_reg_groups(k)

        rule = TransferRule.create!(
          token: token,
          lockup_until: lockup_until,
          sending_group: groups[0],
          receiving_group: groups[1],
          status: :synced,
          synced_at: Time.current
        )

        Sidekiq::Logging.logger(rule)
        Sidekiq::Logging.logger('\n')

        logger.info(rule)
        logger.info('\n')

        rule
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
