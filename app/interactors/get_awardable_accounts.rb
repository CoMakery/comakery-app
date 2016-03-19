class GetAwardableAccounts
  include Interactor

  def call
    accounts = context.accounts
    current_account = context.current_account
    project = context.project

    unless current_account
      context.awardable_accounts = []
      return
    end

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
    real_name = [ user[:profile][:first_name].presence, user[:profile][:last_name].presence ].compact.join(' ')
    [ real_name.presence, "@#{user[:name]}" ].compact.join(' - ')
  end

  def db_formatted_name(auth)
    real_name = [ auth.slack_first_name.presence, auth.slack_last_name.presence ].compact.join(' ')
    [ real_name.presence, "@#{auth.slack_user_name}" ].compact.join(' - ')
  end
end
