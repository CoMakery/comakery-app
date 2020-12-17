class Comakery::Algorand::Tx::App < Comakery::Algorand::Tx
  attr_reader :app_id

  def initialize(blockchain, hash, app_id)
    @algorand = Comakery::Algorand.new(blockchain, nil, app_id)
    @hash = hash
    @app_id = app_id
  end

  def to_object(blockchain_transaction)
    {
      type: 'appl',
      from: blockchain_transaction.source,
      to: nil,
      amount: nil,
      appIndex: app_id,
      appAccounts: app_accounts(blockchain_transaction),
      appArgs: encode_app_args(app_args(blockchain_transaction)),
      appOnComplete: encode_app_transaction_on_completion(app_transaction_on_completion)
    }
  end

  def app_accounts(_blockchain_transaction)
    []
  end

  def app_args(_blockchain_transaction)
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

  def receiver_address
    nil
  end

  def amount
    nil
  end

  def valid_app_id?
    app_id.to_i == transaction_app_id
  end

  def valid_app_accounts?(_blockchain_transaction)
    transaction_app_accounts == []
  end

  def valid_app_args?(blockchain_transaction)
    transaction_app_args == app_args(blockchain_transaction)
  end

  def valid_transaction_on_completion?
    transaction_on_completion == app_transaction_on_completion
  end

  def valid?(blockchain_transaction)
    super \
    && valid_app_id? \
    && valid_app_accounts?(blockchain_transaction) \
    && valid_app_args?(blockchain_transaction) \
    && valid_transaction_on_completion?
  end
end
