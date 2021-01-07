class WalletCreator
  class WrongTokensFormat < StandardError; end

  attr_reader :account, :wallet, :tokens_to_provision, :token_ids_to_provision

  def initialize(account:)
    @account = account
  end

  def call(wallet_params, tokens_to_provision:)
    @wallet = account.wallets.new(wallet_params)
    @tokens_to_provision = tokens_to_provision
    @token_ids_to_provision = tokens_to_provision.map { |t| t.fetch(:token_id, nil) }.compact.map(&:to_i)

    build_wallet_provisions if should_be_provisioned?

    wallet.save if wallet.errors.empty?
    wallet
  end

  private

    def should_be_provisioned?
      token_ids_to_provision.any? && wallet.valid? && valid_tokens_to_provision?
    end

    def valid_tokens_to_provision?
      correct_tokens = Token.available_for_provision.where(id: token_ids_to_provision)
      wrong_tokens = token_ids_to_provision - correct_tokens.pluck(:id)

      if wrong_tokens.any?
        wallet.errors.add(:tokens_to_provision, "Some tokens can't be provisioned: #{wrong_tokens}")
        return false
      end

      true
    end

    def build_wallet_provisions
      token_ids_to_provision.each do |token_to_provision|
        wallet.wallet_provisions.new(token_id: token_to_provision)
      end
    end
end
