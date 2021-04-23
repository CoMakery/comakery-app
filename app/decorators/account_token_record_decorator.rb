class AccountTokenRecordDecorator < Draper::Decorator
  delegate_all

  include Rails.application.routes.url_helpers

  def form_attrs(project)
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
