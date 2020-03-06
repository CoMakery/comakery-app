class AccountTokenRecordDecorator < Draper::Decorator
  delegate_all

  def lockup_until_pretty
    if lockup_until.to_i >= AccountTokenRecord::LOCKUP_UNTIL_MAX.to_i
      '∞'
    elsif lockup_until.to_i <= AccountTokenRecord::LOCKUP_UNTIL_MIN.to_i
      'None'
    else
      lockup_until&.strftime('%b %e, %Y')
    end
  end
end
