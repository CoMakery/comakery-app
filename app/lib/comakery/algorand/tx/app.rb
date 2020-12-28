class Comakery::Algorand::Tx::App < Comakery::Algorand::Tx
  attr_reader :app_id

  def initialize(blockchain_transaction)
    @blockchain_transaction = blockchain_transaction
    @algorand = Comakery::Algorand.new(blockchain_transaction.token.blockchain, nil)
    @hash = blockchain_transaction.tx_hash
    @app_id = blockchain_transaction.token.contract_address
  end

  def to_object
    {
      type: 'appl',
      from: blockchain_transaction.source,
      to: nil,
      amount: nil,
      appIndex: app_id,
      appAccounts: app_accounts,
      appArgs: encode_app_args(app_args),
      appOnComplete: encode_app_transaction_on_completion(app_transaction_on_completion)
    }
  end

  def app_accounts
    []
  end

  def app_args
    []
  end

  def encode_app_args(args)
    args.map { |a| Base64.encode64(a).strip }
  end

  def app_transaction_on_completion
    'noop'
  end

  def encode_app_transaction_on_completion(txonc)
    case txonc
    when 'noop'
      0
    when 'optin'
      1
    end
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

  def valid_app_id?
    transaction_app_id == app_id.to_i
  end

  def valid_app_accounts?
    transaction_app_accounts == app_accounts
  end

  def valid_app_args?
    transaction_app_args == app_args
  end

  def valid_transaction_on_completion?
    transaction_on_completion == app_transaction_on_completion
  end

  def valid?(_)
    super \
    && valid_app_id? \
    && valid_app_accounts? \
    && valid_app_args? \
    && valid_transaction_on_completion?
  end
end
