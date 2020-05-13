class Comakery::EthTx
  attr_reader :eth
  attr_reader :hash

  def initialize(network, hash)
    @eth = Comakery::Eth.new(network)
    @hash = hash
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

  def valid_data?(source, destination, amount)
    return false if status != 1
    return false if from != source.downcase
    return false if to != destination.downcase
    return false if value != amount
    true
  end

  def valid_block?(n)
    return false if block_number <= n
    true
  end

  def valid?(source, destination, amount, block_n)
    return false unless valid_data?(source, destination, amount)
    return false unless valid_block?(block_n)
    true
  end
end
