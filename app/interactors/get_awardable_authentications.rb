class GetAwardableAuthentications
  include Interactor

  def call
    account = context.account
    project = context.project

    unless account && account.slack_auth
      context.awardable_authentications = []
      return
    end

    slack = Comakery::Slack.get(account.slack_auth.token)

    all_awardable_authentications = slack.get_users[:members].map { |user| [api_formatted_name(user), user[:id]] }
    all_awardable_authentications = all_awardable_authentications.sort_by { |member| member.first.downcase.sub(/\A@/, '') }
    all_awardable_authentications = all_awardable_authentications.reject { |member| member.second == account.slack_auth.uid } unless account == project.account

    context.awardable_authentications = all_awardable_authentications
  end

  protected

  def api_formatted_name(user)
    real_name = [user[:profile][:first_name].presence, user[:profile][:last_name].presence].compact.join(' ')
    [real_name.presence, "@#{user[:name]}"].compact.join(' - ')
  end
end
