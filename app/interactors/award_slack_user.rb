class AwardSlackUser
  include Interactor

  def call
    context.fail!(message: "missing slack_user_id") unless context.slack_user_id.present?

    account = Authentication.includes(:account).find_by(slack_user_id: context.slack_user_id).try(:account)
    account ||= create_account(context)
    context.award = Award.new(context.award_params.merge(issuer: context.issuer, account_id: account.id))
    unless context.award.valid?
      context.fail!(message: context.award.errors.full_messages.join(", "))
    end
  end

  private

  def create_account(context)
    response = Swarmbot::Slack.new(context.issuer.slack_auth.slack_token).get_user_info(context.slack_user_id)
    account = Account.create(email: response.profile.email)
    unless account.valid?
      context.fail!(message: account.errors.full_messages.join(", "))
    end
    authentication = Authentication.create(account: account,
                                           provider: "slack",
                                           slack_team_name: context.issuer.slack_auth.slack_team_name,
                                           slack_team_id: context.issuer.slack_auth.slack_team_id,
                                           slack_user_name: response.name,
                                           slack_user_id: context.slack_user_id)

    unless authentication.valid?
      context.fail!(message: authentication.errors.full_messages.join(", "))
    end

    account
  end
end
