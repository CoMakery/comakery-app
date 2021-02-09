class Comakery::Algorand::Tx
  attr_reader :algorand, :hash, :blockchain_transaction

  def initialize(blockchain_transaction)
    @blockchain_transaction = blockchain_transaction
    @algorand = Comakery::Algorand.new(blockchain_transaction.token.blockchain, nil)
    @hash = blockchain_transaction.tx_hash
  end

  def to_object(**_args)
    {
      type: 'pay',
      from: blockchain_transaction.source,
      to: blockchain_transaction.destination,
      amount: blockchain_transaction.amount
    }
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

  def current_round
    data.fetch('current-round', 0)
  end

  def closing_amount
    transaction_data.fetch('closing-amount', nil)
  end

  def sender_address
    transaction_data.fetch('sender', '')
  end

  def receiver_address
    transaction_data.dig('payment-transaction', 'receiver') || ''
  end

  def amount
    transaction_data.dig('payment-transaction', 'amount') || 0
  end

  def confirmed?(_number_of_confirmations = 1)
    confirmed_round.present? && current_round >= confirmed_round
  end

  def valid?(_ = nil)
    return false unless confirmed?
    return false unless valid_addresses?
    return false unless valid_amount?
    return false unless valid_round?

    true
  end

  def valid_addresses?
    blockchain_transaction.source == sender_address &&
      blockchain_transaction.destination == receiver_address
  end

  def valid_amount?
    blockchain_transaction.amount == amount
  end

  def valid_round?
    blockchain_transaction.current_block < confirmed_round
  end
end
