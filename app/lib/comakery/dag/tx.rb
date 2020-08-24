class Comakery::Dag::Tx
  attr_reader :constellation
  attr_reader :hash

  def initialize(network, hash)
    @constellation = Comakery::Constellation.new(network)
    @hash = hash
  end

  def data
    @data ||= constellation.tx(hash)
  end

  def sender
    data['sender']
  rescue StandardError
    nil
  end

  def receiver
    data['receiver']
  rescue StandardError
    nil
  end

  def amount
    data['amount'].to_i
  rescue StandardError
    nil
  end

  def fee
    data['fee'].to_i
  rescue StandardError
    nil
  end

  def snapshot_hash
    data['snapshotHash']
  rescue StandardError
    nil
  end

  def checkpoint_block
    data['checkpointBlock']
  rescue StandardError
    nil
  end

  def confirmed?(_ = nil)
    hash == data&.fetch('hash', nil)
  end

  def valid_data?(source, destination, amount_tx)
    return false unless sender.casecmp?(source)
    return false unless receiver.casecmp?(destination)
    return false unless amount == amount_tx

    true
  end

  def valid?(blockchain_transaction)
    valid_data?(blockchain_transaction.source, blockchain_transaction.destination, blockchain_transaction.amount)
  end

  alias source sender
  alias destination receiver
  alias value amount
end
