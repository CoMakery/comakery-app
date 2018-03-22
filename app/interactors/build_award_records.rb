class BuildAwardRecords
  include Interactor

  # rubocop:disable Metrics/CyclomaticComplexity
  def call
    award_params = context.award_params
    total_tokens_issued = context.total_tokens_issued
    uid = award_params[:uid]
    issuer = context[:issuer]

    context.fail!(message: 'missing uid or email') if uid.blank?
    context.fail!(message: 'missing total_tokens_issued') if total_tokens_issued.blank?

    award_type = AwardType.find_by(id: context.award_type_id)
    project = award_type&.project
    context.fail!(message: 'missing award type') unless project

    quantity = award_params[:quantity].presence || 1

    channel = Channel.find context.channel_id
    authentication = Authentication.includes(:account).find_by(uid: uid)
    account = authentication&.account || create_account(context, channel)

    # TODO: could be done with a award_type.build_award_with_quantity variation of award_type.create_award_with_quantity
    award = Award.new(award_params.merge(
                        account_id: account.id,
                        issuer_id: issuer.id,
                        unit_amount: award_type.amount,
                        quantity: quantity,
                        total_amount: award_type.amount * BigDecimal(quantity)
    ))
    award.award_type = award_type
    award.channel = channel

    # TODO: this should be an award validation
    unless award.total_amount + total_tokens_issued <= project.maximum_tokens
      context.fail!(message: "Sorry, you can't send more awards than the project's maximum number of allowable tokens")
    end

    context.award = award
  end

  private

  def create_account(context, channel)
    uid = context.award_params[:uid]
    if channel
      response = Comakery::Slack.new(channel.authentication.token).get_user_info(uid)
      account = Account.find_or_create_by(email: response.user.profile.email)
      context.fail!(message: account.errors.full_messages.join(', ')) unless account.valid?
      authentication = account.authentications.create(provider: 'slack', uid: uid)
      context.fail!(message: authentication.errors.full_messages.join(', ')) unless authentication.valid?
      channel.team.build_authentication_team authentication
    else
      account = Account.find_or_create_by(email: uid)
      context.fail!(message: account.errors.full_messages.join(', ')) unless account.valid?
    end
    account
  end
end
