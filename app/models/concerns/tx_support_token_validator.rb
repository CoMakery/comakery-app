class TxSupportTokenValidator < ActiveModel::Validator
  def validate(record)
    unless record.token.coin_type_on_ethereum? || record.token.coin_type_dag?
      record.errors.add(:token, "doesn't have transactions support implemented")
    end
  end
end
