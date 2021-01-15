class WalletCreator
  class WrongTokensFormat < StandardError; end

  AVAILABLE_PARAMS = %i[token_id max_balance lockup_until reg_group_id account_id account_frozen].freeze
  # class Validator
  #   def initialize(token, params)
  #     @token = token
  #     @params = params
  #   end
  # end

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

    def tokens_to_provision_params
      return unless tokens_to_provision_raw_params.is_a?(Array)
      return unless tokens_to_provision_raw_params.first.is_a?(ActionController::Parameters)

      @tokens_to_provision_params ||= tokens_to_provision_raw_params.map { |params| params.permit(AVAILABLE_PARAMS) }
    end

    def requested_token_ids_to_provision
      return [] unless tokens_to_provision_params

      @requested_token_ids_to_provision ||= tokens_to_provision_params.map { |t| t.fetch(:token_id, nil) }.compact.map(&:to_i)
    end

    def sanitize_tokens_to_provision(wallet, tokens_to_provision)
      return [] if tokens_to_provision.blank?
    end

    def available_tokens_to_provision
      @available_tokens_to_provision ||= Token.available_for_provision.where(id: requested_token_ids_to_provision).to_a
    end

    def available_token_ids_to_provision
      @available_token_ids_to_provision ||= available_tokens_to_provision.map(&:id)
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

    def build_account_token_records
      tokens_to_provision_params.filter do |params|
        token = available_tokens_to_provision.find { |t| t.id == params[:token_id] }
        next if token.nil? || !token.token_type.operates_with_account_records?

        wallet.account.account_token_records.new(params)
      end
    end
end
