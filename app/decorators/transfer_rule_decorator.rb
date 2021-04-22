class TransferRuleDecorator < Draper::Decorator
  delegate_all

  include Rails.application.routes.url_helpers

  def form_attrs(project)
    {
      model: TransferRule.new,
      url: project_dashboard_transfer_rules_path(project),
      class: 'transfer-rule-form hidden',
      data: {
        target: 'transfer-rules.form'
      }
    }
  end

  def form_attrs_del(project)
    {
      model: self,
      method: :delete,
      url: project_dashboard_transfer_rule_path(project, self),
      class: 'transfer-rule-form'
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
