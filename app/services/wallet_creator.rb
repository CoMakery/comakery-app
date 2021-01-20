class WalletCreator
  class WrongTokensFormat < StandardError; end

  attr_reader :account, :errors

  def initialize(account:)
    @account = account
  end

  def call(wallets_params)
    errors = {}
    wallets = wallets_params.map.with_index do |wallet_attrs, i|
      tokens_to_provision = wallet_attrs.delete(:tokens_to_provision)
      wallet_attrs[:_blockchain] = wallet_attrs.delete(:blockchain)

      wallet = account.wallets.new(wallet_attrs)

      provision = Provision.new(wallet, tokens_to_provision)

      if provision.should_be_provisioned?
        provision.build_wallet_provisions
        provision.build_account_token_records
      end

      errors[i] = provision.wallet.errors if provision.wallet.errors.any?

      provision.wallet
    end

    account.save if errors.empty?
    [wallets, errors]
  end
end

class WalletCreator::Provision
  ACCOUNT_RECORD_PARAMS = %w[max_balance lockup_until reg_group_id account_frozen].freeze

  attr_reader :wallet, :params

  def initialize(wallet, params)
    @wallet = wallet
    @params = params
  end

  def should_be_provisioned?
    wallet.valid? && validate_params && validate_tokens_availability
  end

  def build_wallet_provisions
    params.each do |provision_params|
      token_id = provision_params.fetch(:token_id)
      wallet.wallet_provisions.new(token_id: token_id)
    end
  end

  def build_account_token_records
    params_with_required_tokens_to_fill_account_record.each do |token_params|
      wallet.account_token_records.new(token_params.merge(account: wallet.account))
    end
  end

  private

    def available_tokens_to_provision
      @available_tokens_to_provision ||= Token.available_for_provision.where(id: params.map { |p| p[:token_id] })
    end

    def tokens_to_fill_account_record
      available_tokens_to_provision.filter { |token| token.token_type.operates_with_account_records? }
    end

    def validate_params
      validate_params_type
      validate_token_id_provided
      validate_params_for_account_records

      wallet.errors.empty?
    end

    def validate_params_type
      error_message = 'Wrong format. It must be an Array.'

      if params.is_a?(Array)
        add_error(error_message) if params.first.present? && !params.first.is_a?(ActionController::Parameters) && !params.first.is_a?(Hash)
      else
        add_error(error_message) if params
        @params = []
      end
    end

    def validate_token_id_provided
      add_error('token_id param must be provided') unless params.all? { |p| p.key?(:token_id) }
    end

    def validate_params_for_account_records
      params_with_required_tokens_to_fill_account_record.each do |token_params|
        missed_keys = ACCOUNT_RECORD_PARAMS - token_params.keys.map(&:to_s)
        add_error("Token #{token_params[:token_id]} requires to provide additional params: #{missed_keys.join(', ')}") if missed_keys.any?
      end
    end

    def validate_tokens_availability
      unavailable_token_ids = params.map { |t| t.fetch(:token_id).to_i } - available_tokens_to_provision.pluck(:id)
      add_error("Some tokens can't be provisioned: #{unavailable_token_ids}") if unavailable_token_ids.any?
      wallet.errors.empty?
    end

    def add_error(error_message)
      wallet.errors.add(:tokens_to_provision, error_message)
    end

    def params_with_required_tokens_to_fill_account_record
      @params_with_required_tokens_to_fill_account_record ||=
        begin
          params.filter do |token_params|
            tokens_to_fill_account_record.any? { |token| token.id == token_params[:token_id].to_i }
          end
        end
    end
end
