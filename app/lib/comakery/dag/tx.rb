class Comakery::Dag::Tx
  attr_reader :constellation
  attr_reader :hash

  def initialize(host, hash)
    @constellation = Comakery::Constellation.new(host)
    @hash = hash
  end

  def data
    @data ||= constellation.tx(hash)
  end

  def sender
    data.fetch('sender', nil)
  end

  def receiver
    data.fetch('receiver', nil)
  end

  def amount
    data.fetch('amount', nil)&.to_i
  end

  def fee
    data.fetch('fee', nil)&.to_i
  end

  def snapshot_hash
    data.fetch('snapshotHash', nil)
  end

  def checkpoint_block
    data.fetch('checkpointBlock', nil)
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
