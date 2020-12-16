class Comakery::Algorand::Tx::App < Comakery::Algorand::Tx
  attr_reader :app_id

  def initialize(blockchain, hash, app_id)
    @algorand = Comakery::Algorand.new(blockchain, nil, app_id)
    @hash = hash
    @app_id = app_id
  end

  def transaction_app_id
    transaction_data.dig('application-transaction', 'application-id')
  end

  def transaction_app_accounts
    transaction_data.dig('application-transaction', 'accounts')
  end

  def transaction_app_args
    transaction_data.dig('application-transaction', 'application-args')&.map do |arg|
      Base64.decode64(arg)
    end
  end

  def transaction_on_completion
    transaction_data.dig('application-transaction', 'on-completion')
  end

  def receiver_address
    nil
  end

  # In the minimal App token unit
  # amount 100 mean 1.00 when App decimal is 2
  def amount
    0 # TODO: Fix me
  end

  def valid_app_id?
    app_id.to_i == transaction_app_id
  end

  def valid_app_accounts?(_blockchain_transaction)
    [] == transaction_app_accounts
  end

  def valid_app_args?(_blockchain_transaction)
    [] == transaction_app_args
  end

  def valid?(blockchain_transaction)
    super && valid_app_id? && valid_app_accounts?(blockchain_transaction) && valid_app_args?(blockchain_transaction)
  end
end
