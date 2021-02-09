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
