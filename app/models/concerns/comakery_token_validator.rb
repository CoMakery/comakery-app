class ComakeryTokenValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:token, 'is not a Comakery Security Token') unless record.token._token_type_comakery_security_token?
  end
end
