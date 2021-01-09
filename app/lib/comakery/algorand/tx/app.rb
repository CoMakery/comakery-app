class Comakery::Algorand::Tx::App < Comakery::Algorand::Tx
  attr_reader :app_id

  def initialize(blockchain, hash, app_id)
    @algorand = Comakery::Algorand.new(blockchain, nil, app_id)
    @hash = hash
    @app_id = app_id
  end

  def transaction_app_id
    transaction_data.dig('application-transaction', 'application-id')
  end

  def receiver_address
    nil
  end

  # In the minimal App token unit
  # amount 100 mean 1.00 when App decimal is 2
  def amount
    0 # TODO: Fix me
  end

  def valid?(blockchain_transaction)
    super && app_id.to_i == transaction_app_id
  end
end
