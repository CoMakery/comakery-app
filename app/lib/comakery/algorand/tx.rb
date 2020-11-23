class Comakery::Algorand::Tx
  attr_reader :algorand, :hash

  def initialize(blockchain, hash)
    @algorand = Comakery::Algorand.new(blockchain, nil)
    @hash = hash
  end

  def data
    @data ||= algorand.transaction_details(hash).to_h
  end

  def transaction_data
    @transaction_data ||= data.fetch('transactions', []).first
  end

  def confirmed_round
    transaction_data&.fetch('confirmed-round', nil)
  end

  def confirmed?(_number_of_confirmations = 1)
    confirmed_round.present?
  end
end
