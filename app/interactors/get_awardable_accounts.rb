class GetAwardableAccounts
  include Interactor

  def call
    accounts = context.accounts
    current_account = context.current_account
    project = context.project

    all_awardable_accounts = (db_slack_users(accounts) + api_slack_users(current_account)).to_h

    all_awardable_accounts.delete(current_account.slack_auth.slack_user_id) unless current_account == project.owner_account

    context.awardable_accounts = all_awardable_accounts.invert.to_a
  end

  protected
  def db_slack_users(accounts)
    accounts.map { |a| [a.slack_auth.slack_user_id, db_formatted_name(a.slack_auth)] }.sort
  end

  def api_slack_users(current_account)
    slack = Comakery::Slack.get(current_account.slack_auth.slack_token)
    slack.get_users[:members].map { |user| [user[:id], api_formatted_name(user)] }.sort
  end

  def api_formatted_name(user)
    if user[:profile][:first_name].present? || user[:profile][:last_name].present?
      name = ''
      name << user[:profile][:first_name] + ' ' if user[:profile][:first_name].present?
      name << user[:profile][:last_name] + ' ' if user[:profile][:last_name].present?
      name << "- @#{user[:name]}"
    else
      "@#{user[:name]}"
    end
  end

  def db_formatted_name(auth)
    if auth.slack_first_name.present? || auth.slack_last_name.present?
      name = ''
      name << auth.slack_first_name + ' ' if auth.slack_first_name.present?
      name << auth.slack_last_name + ' ' if auth.slack_last_name.present?
      name << "- @#{auth.slack_user_name}"
    else
      "@#{auth.slack_user_name}"
    end
  end
end
