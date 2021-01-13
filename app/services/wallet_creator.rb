class WalletCreator
  class WrongTokensFormat < StandardError; end

  attr_reader :account

  def initialize(account:)
    @account = account
  end

  def call(wallets_params)
    errors = {}

    wallets = wallets_params.map.with_index do |wallet_attrs, i|
      tokens_to_provision = wallet_attrs.delete(:tokens_to_provision)
      wallet_attrs[:_blockchain] = wallet_attrs.delete(:blockchain)

      wallet = account.wallets.new(wallet_attrs)

      # This will init the errors object and allow to add custom errors later on with #errors.add
      wallet.validate

      tokens_to_provision = sanitize_tokens_to_provision(wallet, tokens_to_provision)

      build_wallet_provisions(wallet, tokens_to_provision) if should_be_provisioned?(wallet, tokens_to_provision)

      errors[i] = wallet.errors if wallet.errors.any?

      wallet
    end

    account.save if errors.empty?

    [wallets, errors]
  end

  private

    def sanitize_tokens_to_provision(wallet, tokens_to_provision)
      return [] if tokens_to_provision.blank?

      parsed_token_ids = JSON.parse(tokens_to_provision.to_s)
      raise WalletCreator::WrongTokensFormat unless parsed_token_ids.is_a?(Array)

      parsed_token_ids
    rescue JSON::ParserError, WalletCreator::WrongTokensFormat
      wallet.errors.add(:tokens_to_provision, 'Wrong format. It must be an Array. For example: [1,5]')
      []
    end

    def should_be_provisioned?(wallet, tokens_to_provision)
      tokens_to_provision.any? && wallet.valid? && valid_tokens_to_provision?(wallet, tokens_to_provision)
    end

    def valid_tokens_to_provision?(wallet, tokens_to_provision)
      correct_tokens = Token.available_for_provision.where(id: tokens_to_provision)
      wrong_tokens = tokens_to_provision.map(&:to_i) - correct_tokens.pluck(:id)

      if wrong_tokens.any?
        wallet.errors.add(:tokens_to_provision, "Some tokens can't be provisioned: #{wrong_tokens}")
        return false
      end

      true
    end

    def build_wallet_provisions(wallet, tokens_to_provision)
      tokens_to_provision.each do |token_to_provision|
        wallet.wallet_provisions.new(token_id: token_to_provision)
      end
    end
end
