class GetRewardableAccounts
  include Interactor

  def call
    accounts = context.accounts
    current_account = context.current_account

    db_slack_users = accounts.map { |a| [a.slack_auth.slack_user_id, db_formatted_name(a.slack_auth)] }.sort
    api_slack_users = Swarmbot::Slack.get(current_account.slack_auth.slack_token).get_users.map { |user| [user[:id], api_formatted_name(user)] }.sort

    context.rewardable_accounts = (db_slack_users + api_slack_users).to_h.invert.to_a
  end

  private

  def api_formatted_name(user)
    if user[:profile][:first_name] && user[:profile][:last_name]
      "#{user[:profile][:first_name]} #{user[:profile][:last_name]} - #{user[:name]}"
    else
      user[:name]
    end
  end

  def db_formatted_name(auth)
    if auth.slack_first_name && auth.slack_last_name
      "#{auth.slack_first_name} #{auth.slack_last_name} - #{auth.slack_user_name}"
    else
      auth.slack_user_name
    end
  end
end
