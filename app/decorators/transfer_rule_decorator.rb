class TransferRuleDecorator < Draper::Decorator
  delegate_all

  include Rails.application.routes.url_helpers

  def form_attrs(project)
    if project.token.blockchain.supported_by_ore_id?
      form_attrs_ore_id(project)
    else
      form_attrs_eth(project)
    end
  end

  def form_attrs_ore_id(project)
    {
      model: TransferRule.new,
      url: project_dashboard_transfer_rules_path(project),
      class: 'transfer-rule-form hidden',
      data: {
        target: 'transfer-rules.form'
      }
    }
  end

  def form_attrs_eth(project)
    {
      model: TransferRule.new,
      url: project_dashboard_transfer_rules_path(project),
      class: 'transfer-rule-form hidden',
      data: {
        controller: 'transfer-rule-form',
        target: 'transfer-rule-form.form transfer-rules.form',
        'transfer-rule-form-transfer-rules-path' => api_v1_project_transfer_rules_path(project_id: project.id),
        'transfer-rule-form-transactions-path' => api_v1_project_blockchain_transactions_path(project_id: project.id)
      }.merge(project.token.decorate.eth_data('transfer-rule-form'))
    }
  end

  def form_attrs_del(project)
    if project.token.blockchain.supported_by_ore_id?
      form_attrs_del_ore_id(project)
    else
      form_attrs_del_eth(project)
    end
  end

  def form_attrs_del_ore_id(project)
    {
      model: self,
      method: :delete,
      url: project_dashboard_transfer_rule_path(project, self),
      class: 'transfer-rule-form'
    }
  end

  def form_attrs_del_eth(project)
    {
      model: self,
      method: :delete,
      url: project_dashboard_transfer_rule_path(project, self),
      class: 'transfer-rule-form',
      data: {
        controller: 'transfer-rule-form',
        target: 'transfer-rule-form.form',
        'transfer-rule-form-transfer-rules-path' => api_v1_project_transfer_rules_path(project_id: project.id),
        'transfer-rule-form-transactions-path' => api_v1_project_blockchain_transactions_path(project_id: project.id)
      }.merge(
        eth_data
      ).merge(
        project.token.decorate.eth_data('transfer-rule-form')
      )
    }
  end

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
