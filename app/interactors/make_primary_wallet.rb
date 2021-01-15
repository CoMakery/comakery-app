class MakePrimaryWallet
  include Interactor

  delegate :account, :wallet, to: :context

  def call
    ActiveRecord::Base.transaction do
      # rubocop:disable Rails/SkipsModelValidations
      account_blockchain_wallets.update_all(primary_wallet: false)
      wallet.update!(primary_wallet: true)
    end
  rescue ActiveRecord::RecordInvalid => _e
    context.fail!(error: wallet.errors.full_messages.join(', '))
  end

  private

    def account_blockchain_wallets
      account.wallets.where(_blockchain: wallet._blockchain)
    end
end
