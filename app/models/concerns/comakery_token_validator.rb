class ComakeryTokenValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:token, 'is not a Comakery Security Token') unless record.token.coin_type_comakery?
  end
end
