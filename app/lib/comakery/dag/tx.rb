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
  rescue
    nil
  end

  def receiver
    data['receiver']
  rescue
    nil
  end

  def amount
    data['amount'].to_i
  rescue
    nil
  end

  def fee
    data['fee'].to_i
  rescue
    nil
  end

  def snapshot_hash
    data['snapshotHash']
  rescue
    nil
  end

  def checkpoint_block
    data['checkpointBlock']
  rescue
    nil
  end

  def confirmed?(_ = nil)
    hash == data&.fetch('hash', nil)
  end

  def valid?
    confirmed?
  end
end
