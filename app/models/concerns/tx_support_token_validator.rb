class TxSupportTokenValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:token, "doesn't have transactions support implemented") unless record.token._token_type_on_ethereum? || record.token._token_type_dag?
  end
end
