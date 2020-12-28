class WalletCreator
  class WrongTokensFormat < StandardError; end

  attr_reader :account, :wallet, :tokens_to_provision

  def initialize(account:)
    @account = account
  end

  def call(wallet_params, tokens_to_provision: [])
    @wallet = account.wallets.new(wallet_params)
    @tokens_to_provision = sanitize_tokens_to_provision(tokens_to_provision)

    build_wallet_provisions if should_be_provisioned?

    wallet.save if wallet.errors.empty?
    wallet
  end

  private

    def sanitize_tokens_to_provision(tokens_to_provision)
      return [] if tokens_to_provision.blank?

      parsed_token_ids = JSON.parse(tokens_to_provision.to_s)
      raise WalletCreator::WrongTokensFormat unless parsed_token_ids.is_a?(Array)

      parsed_token_ids
    rescue JSON::ParserError, WalletCreator::WrongTokensFormat
      wallet.errors.add(:tokens_to_provision, 'Wrong format. It must be an Array. For example: [1,5]')
      []
    end

    def should_be_provisioned?
      tokens_to_provision.any? && wallet.valid? && valid_tokens_to_provision?
    end

    def valid_tokens_to_provision?
      correct_tokens = Token.available_for_provision.where(id: tokens_to_provision)
      wrong_tokens = tokens_to_provision.map(&:to_i) - correct_tokens.pluck(:id)

      if wrong_tokens.any?
        wallet.errors.add(:tokens_to_provision, "Some tokens can't be provisioned: #{wrong_tokens}")
        return false
      end

      true
    end

    def build_wallet_provisions
      tokens_to_provision.each do |token_to_provision|
        wallet.wallet_provisions.new(token_id: token_to_provision)
      end
    end
end
