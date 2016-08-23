class AwardDecorator < Draper::Decorator
  delegate_all

  def proof_id_short
    "#{object.proof_id[0...20]}..."
  end

  def ethereum_transaction_address_short
    "#{award.ethereum_transaction_address[0...10]}..."
  end
end
