class Comakery::Eth::Tx
  attr_reader :eth
  attr_reader :hash
  attr_reader :blockchain_transaction

  def initialize(host, hash, blockchain_transaction = nil)
    @eth = Comakery::Eth.new(host)
    @hash = hash
    @blockchain_transaction = blockchain_transaction
  end

  def to_object(**_args)
    {
      from: blockchain_transaction.source,
      to: blockchain_transaction.destination,
      value: encode_value(blockchain_transaction.amount)
    }
  end

  def encode_value(val)
    '0x' + val.to_i.to_s(16)
  end

  def data
    @data ||= eth.client.eth_get_transaction_by_hash(hash)&.fetch('result', nil)
  end

  def receipt
    @receipt ||= eth.client.eth_get_transaction_receipt(hash)&.fetch('result', nil)
  end

  def block
    @block ||= eth.client.eth_get_block_by_number(block_number, true)&.fetch('result', nil)
  end

  def block_number
    data&.fetch('blockNumber', nil)&.to_i(16)
  end

  def block_time
    Time.zone.at block&.fetch('timestamp', nil)&.to_i(16)
  end

  def value
    data&.fetch('value', nil)&.to_i(16)
  end

  def from
    data&.fetch('from', nil)
  end

  def to
    data&.fetch('to', nil)
  end

  def input
    data&.fetch('input', nil)&.split('0x')&.last
  end

  def status
    receipt&.fetch('status', nil)&.to_i(16)
  end

  def confirmed?(number_of_confirmations = 1)
    return false unless block_number

    eth.current_block - block_number >= number_of_confirmations
  end

  def valid_block?
    block_number > blockchain_transaction.current_block
  end

  def valid_status?
    status == 1
  end

  def valid_from?
    from == blockchain_transaction.source.downcase
  end

  def valid_to?
    to == blockchain_transaction.destination.downcase
  end

  def valid_amount?
    value == blockchain_transaction.amount
  end

  def valid?(_ = nil)
    valid_block? \
    && valid_status? \
    && valid_from? \
    && valid_to? \
    && valid_amount?
  end
end
