class Comakery::Dag::Tx
  attr_reader :hash

  def initialize(hash)
    @hash = hash
    @host = if ENV.key?('CONSTELLATION_BLOCK_EXPLORER_URL')
      ENV.fetch('CONSTELLATION_BLOCK_EXPLORER_URL')
    else
      raise 'Please set CONSTELLATION_BLOCK_EXPLORER_URL env variable.'
    end
  end

  def data
    @data ||= JSON.parse((open "https://#{@host}/transactions/#{@hash}").read)
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
end
