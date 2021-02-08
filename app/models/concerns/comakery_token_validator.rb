class ComakeryTokenValidator < ActiveModel::Validator
  def validate(record)
    return if record.token._token_type_comakery_security_token?
    return if record.token._token_type_algorand_security_token?

    record.errors.add(:token, 'is not a Comakery Security Token')
  end
end
