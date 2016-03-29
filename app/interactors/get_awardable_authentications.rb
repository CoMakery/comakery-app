class GetAwardableAuthentications
  include Interactor

  def call
    authentications = context.authentications
    current_account = context.current_account
    project = context.project

    unless current_account
      context.awardable_authentications = []
      return
    end

    all_awardable_authentications = (db_slack_users(authentications) + api_slack_users(current_account)).to_h

    all_awardable_authentications.delete(current_account.slack_auth.slack_user_id) unless current_account == project.owner_account

    context.awardable_authentications = all_awardable_authentications.invert.to_a
  end

  protected

  def db_slack_users(authentications)
    authentications.map { |a| [a.slack_user_id, db_formatted_name(a)] }.sort_by(&:second)
  end

  def api_slack_users(current_account)
    slack = Comakery::Slack.get(current_account.slack_auth.slack_token)
    slack.get_users[:members].map { |user| [user[:id], api_formatted_name(user)] }.sort_by(&:second)
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
