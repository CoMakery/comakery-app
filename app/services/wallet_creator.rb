class WalletCreator
  class WrongTokensFormat < StandardError; end

  AVAILABLE_PARAMS = %i[token_id max_balance lockup_until reg_group_id account_id account_frozen].freeze
  # class Validator
  #   def initialize(token, params)
  #     @token = token
  #     @params = params
  #   end
  # end

  attr_reader :account, :wallet, :tokens_to_provision_raw_params

  def initialize(account:)
    @account = account
  end

  def call(wallet_params, tokens_to_provision:)
    @wallet = account.wallets.new(wallet_params)
    @tokens_to_provision_raw_params = tokens_to_provision

    if should_be_provisioned?
      build_wallet_provisions
      build_account_token_records
    end

    wallet.save if wallet.errors.empty?
    wallet
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

    def available_tokens_to_provision
      @available_tokens_to_provision ||= Token.available_for_provision.where(id: requested_token_ids_to_provision).to_a
    end

    def available_token_ids_to_provision
      @available_token_ids_to_provision ||= available_tokens_to_provision.map(&:id)
    end

    def should_be_provisioned?
      tokens_to_provision_params && wallet.valid? && valid_tokens_to_provision?
    end

    def valid_tokens_to_provision?
      # TODO: Improve validations to check account_token_records params
      wrong_tokens = requested_token_ids_to_provision - available_token_ids_to_provision

      if wrong_tokens.any?
        wallet.errors.add(:tokens_to_provision, "Some tokens can't be provisioned: #{wrong_tokens}")
        return false
      end

      true
    end

    def build_wallet_provisions
      requested_token_ids_to_provision.each do |token_id|
        wallet.wallet_provisions.new(token_id: token_id)
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
