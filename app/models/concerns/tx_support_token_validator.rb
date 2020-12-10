class TxSupportTokenValidator < ActiveModel::Validator
  def validate(record)
    return if record.token._token_type_on_ethereum?
    return if record.token._token_type_dag?
    return if record.token._token_type_algo?
    return if record.token._token_type_asa?
    return if record.token._token_type_algorand_security_token?

    record.errors.add(:token, "doesn't have transactions support implemented")
  end
end
