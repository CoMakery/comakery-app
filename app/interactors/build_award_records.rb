class BuildAwardRecords
  include Interactor

  # rubocop:disable Metrics/CyclomaticComplexity
  def call
    slack_user_id = context.slack_user_id
    award_params = context.award_params
    total_tokens_issued = context.total_tokens_issued
    issuer = context.issuer

    context.fail!(message: 'missing slack_user_id') if slack_user_id.blank?
    context.fail!(message: 'missing total_tokens_issued') if total_tokens_issued.blank?

    award_type = AwardType.find_by(id: award_params[:award_type_id])
    project = award_type&.project
    context.fail!(message: 'missing award type') unless project

    quantity = award_params[:quantity].presence || 1

    authentication = Authentication.includes(:account).find_by(slack_user_id: slack_user_id)
    authentication ||= create_authentication(context)

    # TODO: could be done with a award_type.build_award_with_quantity variation of award_type.create_award_with_quantity
    award = Award.new(award_params.merge(
                        issuer: issuer,
                        authentication_id: authentication.id,
                        unit_amount: award_type.amount,
                        quantity: quantity,
                        total_amount: award_type.amount * BigDecimal(quantity)
    ))

    # TODO: this should be an award validation
    unless award.total_amount + total_tokens_issued <= project.maximum_tokens
      context.fail!(message: "Sorry, you can't send more awards than the project's maximum number of allowable tokens")
    end

    if award.total_amount + project.total_month_awarded >= project.maximum_royalties_per_month
      context.fail!(message: "Sorry, you can't send more awards this month than the project's maximum number of allowable tokens per month")
    end

    unless award.valid?
      context.award = award
      context.fail!(message: award.errors.full_messages.join(', '))
      return
    end

    context.award = award
  end

  private

  def create_authentication(context)
    response = Comakery::Slack.new(context.issuer.slack_auth.slack_token).get_user_info(context.slack_user_id)
    account = Account.find_or_create_by(email: response.user.profile.email)
    unless account.valid?
      context.fail!(message: account.errors.full_messages.join(', '))
    end
    authentication = Authentication.create(account: account,
                                           provider: 'slack',
                                           slack_team_name: context.project.slack_team_name,
                                           slack_team_id: context.project.slack_team_id,
                                           slack_team_image_34_url: context.project.slack_team_image_34_url,
                                           slack_team_image_132_url: context.project.slack_team_image_132_url,
                                           slack_user_name: response.user.name,
                                           slack_user_id: context.slack_user_id)

    unless authentication.valid?
      context.fail!(message: authentication.errors.full_messages.join(', '))
    end

    authentication
  end
end
