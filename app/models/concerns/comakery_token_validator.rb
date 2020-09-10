class ComakeryTokenValidator < ActiveModel::Validator
  def validate(record)
    unless record.token._token_type_comakery?
      record.errors.add(:token, 'is not a Comakery Security Token')
    end
  end
end
