class Comakery::Algorand::Tx::App < Comakery::Algorand::Tx
  attr_reader :app_id

  def initialize(blockchain_transaction)
    @blockchain_transaction = blockchain_transaction
    @algorand = Comakery::Algorand.new(blockchain_transaction.token.blockchain, nil)
    @hash = blockchain_transaction.tx_hash
    @app_id = blockchain_transaction.token.contract_address.to_i
  end

  def to_object(**args)
    {
      type: 'appl',
      from: blockchain_transaction.source,
      appIndex: app_id,
      appAccounts: app_accounts,
      appArgs: send("encode_app_args_#{args[:app_args_format]}"),
      appOnComplete: encode_app_transaction_on_completion(app_transaction_on_completion)
    }
  end

  def app_accounts
    []
  end

  def app_args
    []
  end

  # Note: ChainJS appArgs format
  def encode_app_args_hex
    app_args.map do |a|
      case a
      when String
        '0x' + a.unpack1('H*')
      when Integer
        i = a.to_s(16)
        i = '0' + i if i.size.odd?

        '0x' + i
      else
        raise "Unsupported app argument: #{a}:#{a.class}"
      end
    end
  end

  # Note: Algosinger appArgs format
  def encode_app_args_base64_and_uint
    app_args.map do |a|
      case a
      when String
        Base64.encode64(a).strip
      when Integer
        encode_int_as_bytes(a)
      else
        raise "Unsupported app argument: #{a}:#{a.class}"
      end
    end
  end

  # Note: Algoexplorer appArgs format
  def encode_app_args_base64
    app_args.map do |a|
      case a
      when String
        Base64.encode64(a).strip
      when Integer
        Base64.encode64(encode_int_as_bytes(a).pack('c*')).strip
      else
        raise "Unsupported app argument: #{a}:#{a.class}"
      end
    end
  end

  def encode_int_as_bytes(int)
    [int].pack('N').bytes.drop_while(&:zero?)
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
    transaction_app_id == app_id
  end

  def valid_app_accounts?
    transaction_app_accounts == app_accounts
  end

  def valid_app_args?
    # NOTE: Algoexplorer always returns all args as base64 regardless type

    transaction_app_args == to_object(app_args_format: :base64)[:appArgs]
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
