class TxSupportTokenValidator < ActiveModel::Validator
  def validate(record)
    unless record.token._token_type_on_ethereum? || record.token._token_type_dag?
      record.errors.add(:token, "doesn't have transactions support implemented")
    end
  end
end
