class AwardDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def proof_id_short
    "#{object.proof_id[0...20]}..."
  end

  def ethereum_transaction_address_short
    if object.ethereum_transaction_address
      "#{object.ethereum_transaction_address[0...10]}..."
    else
      nil
    end
  end

  def ethereum_transaction_explorer_url
    if object.ethereum_transaction_address
      "https://#{Rails.application.config.ethercamp_subdomain}.ether.camp/transaction/#{object.ethereum_transaction_address}"
    else
      nil
    end
  end

  def unit_amount_pretty
    number_with_delimiter(award.unit_amount, :delimiter => ',')
  end

  def total_amount_pretty
    number_with_delimiter(award.total_amount, :seperator => ',')
  end
end
