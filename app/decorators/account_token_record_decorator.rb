class AccountTokenRecordDecorator < Draper::Decorator
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
      model: self,
      url: project_dashboard_accounts_path(project),
      method: :post,
      class: 'account-form',
      data: {
        controller: 'account-form-controls',
        target: 'account-form-controls.form'
      }
    }
  end

  def form_attrs_eth(project)
    {
      model: self,
      url: project_dashboard_account_path(project, account),
      class: 'account-form',
      method: :get,
      data: {
        controller: 'account-form account-form-controls',
        target: 'account-form.form account-form-controls.form',
        'account-form-address' => account.address_for_blockchain(project.token._blockchain),
        'account-form-account-id' => account.id,
        'account-form-account-token-records-path' => project_dashboard_accounts_path(project_id: project.id),
        'account-form-transactions-path' => api_v1_project_blockchain_transactions_path(project_id: project.id)
      }.merge(project.token.decorate.eth_data('account-form'))
    }
  end

  def lockup_until_pretty
    if lockup_until.to_i > 100.years.from_now.to_i
      '> 100 years'
    elsif lockup_until.to_i <= AccountTokenRecord::LOCKUP_UNTIL_MIN.to_i
      'None'
    else
      lockup_until&.strftime('%b %e, %Y')
    end
  end
end
