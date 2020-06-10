class TransferRuleDecorator < Draper::Decorator
  delegate_all

  def eth_data(controller = 'transfer-rule-form')
    {
      "#{controller}-rule-from-group-id" => sending_group.id,
      "#{controller}-rule-to-group-id" => receiving_group.id,
      "#{controller}-rule-from-group-blockchain-id" => sending_group.blockchain_id,
      "#{controller}-rule-to-group-blockchain-id" => receiving_group.blockchain_id,
      "#{controller}-rule-lockup-until" => lockup_until.strftime('%b %e, %Y')
    }
  end

  def lockup_until_pretty
    if lockup_until.to_i > 100.years.from_now.to_i
      '> 100 years'
    elsif lockup_until.to_i == TransferRule::LOCKUP_UNTIL_MIN.to_i
      '∞'
    elsif lockup_until.to_i == TransferRule::LOCKUP_UNTIL_MIN.to_i + 1
      'None'
    else
      lockup_until&.strftime('%b %e, %Y')
    end
  end
end
