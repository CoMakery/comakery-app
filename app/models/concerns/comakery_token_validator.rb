class ComakeryTokenValidator < ActiveModel::Validator
  def validate(record)
    unless record.token.coin_type_comakery?
      record.errors.add(:token, 'is not a Comakery Security Token')
    end
  end
end
