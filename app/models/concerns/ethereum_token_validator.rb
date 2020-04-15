class EthereumTokenValidator < ActiveModel::Validator
  def validate(record)
    unless record.token.coin_type_on_ethereum?
      record.errors.add(:token, 'is not an Ethereum Token')
    end
  end
end
