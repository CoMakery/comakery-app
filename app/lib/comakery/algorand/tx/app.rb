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

  def encode_app_args(args, int_base64 = false)
    args.map do |a|
      case a
      when String
        encode_str(a)
      when Integer
        int_base64 ? encode_int_base64(a) : encode_int(a)
      else
        raise "Unsupported app argument: #{a}:#{a.class}"
      end
    end
  end

  def encode_str(str)
    Base64.encode64(str).strip
  end

  def encode_int(int)
    int.to_s(16).chars.each_slice(2).map { |s| s.join.to_i(16) }
  end

  # NOTE: Algoexplorer always returns all args as base64 regardless type
  def encode_int_base64(int)
    Base64.encode64(encode_int(int).pack('c')).strip
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
    transaction_data.dig('application-transaction', 'application-args')
  end

  def transaction_on_completion
    transaction_data.dig('application-transaction', 'on-completion')
  end

  def receiver_address
    transaction_app_accounts.first
  end

  def valid_app_id?
    transaction_app_id == to_object[:appIndex].to_i
  end

  def valid_app_accounts?
    transaction_app_accounts == to_object[:appAccounts]
  end

  def valid_app_args?
    # NOTE: Algoexplorer always returns all args as base64 regardless type

    transaction_app_args == encode_app_args(app_args, true)
  end

  def valid_transaction_on_completion?
    # NOTE: Algoexplorer always returns transaction_on_completion as string

    transaction_on_completion == app_transaction_on_completion
  end

  def valid?(_ = nil)
    super \
    && valid_app_id? \
    && valid_app_accounts? \
    && valid_app_args? \
    && valid_transaction_on_completion?
  end
end
