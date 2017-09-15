class GetAwardableAuthentications
  include Interactor

  def call
    current_account = context.current_account
    project = context.project

    unless current_account
      context.awardable_authentications = []
      return
    end

    slack = Comakery::Slack.get(current_account.slack_auth.slack_token)

    all_awardable_authentications = slack.get_users[:members].map { |user| [api_formatted_name(user), user[:id]] }
    all_awardable_authentications = all_awardable_authentications.sort_by { |member| member.first.downcase.sub(/\A@/, '') }
    all_awardable_authentications = all_awardable_authentications.reject { |member| member.second == current_account.slack_auth.slack_user_id } unless current_account == project.owner_account

    context.awardable_authentications = all_awardable_authentications
  end

  protected

  def api_formatted_name(user)
    real_name = [user[:profile][:first_name].presence, user[:profile][:last_name].presence].compact.join(' ')
    [real_name.presence, "@#{user[:name]}"].compact.join(' - ')
  end
end
