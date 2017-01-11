class BuildAwardRecords
  include Interactor

  def call
    slack_user_id = context.slack_user_id
    award_params = context.award_params
    total_coins_issued = context.total_coins_issued
    issuer = context.issuer

    context.fail!(message: "missing slack_user_id") unless slack_user_id.present?
    context.fail!(message: "missing total_coins_issued") unless total_coins_issued.present?

    award_type = AwardType.find_by(id: award_params[:award_type_id])
    project = award_type&.project
    context.fail!(message: "missing award type") unless project
    unless total_coins_issued + award_type.amount <= project.maximum_coins
      context.fail!(message: "Sorry, you can't send more awards than the project's maximum number of allowable coins")
    end

    authentication = Authentication.includes(:account).find_by(slack_user_id: slack_user_id)
    authentication ||= create_authentication(context)
    award_params["quantity"] ||= 1
    award = Award.new(award_params.merge(
        issuer: issuer,
        authentication_id: authentication.id,
        unit_amount: award_type.amount,
        quantity: award_params["quantity"],
        total_amount: award_type.amount * BigDecimal(award_params["quantity"])
    ))

    unless award.valid?
      context.award = award
      context.fail!(message: award.errors.full_messages.join(", "))
      return
    end

    context.award = award
  end

  private

  def create_authentication(context)
    response = Comakery::Slack.new(context.issuer.slack_auth.slack_token).get_user_info(context.slack_user_id)
    account = Account.find_or_create_by(email: response.user.profile.email)
    unless account.valid?
      context.fail!(message: account.errors.full_messages.join(", "))
    end
    authentication = Authentication.create(account: account,
                                           provider: "slack",
                                           slack_team_name: context.project.slack_team_name,
                                           slack_team_id: context.project.slack_team_id,
                                           slack_team_image_34_url: context.project.slack_team_image_34_url,
                                           slack_team_image_132_url: context.project.slack_team_image_132_url,
                                           slack_user_name: response.user.name,
                                           slack_user_id: context.slack_user_id)

    unless authentication.valid?
      context.fail!(message: authentication.errors.full_messages.join(", "))
    end

    authentication
  end
end
