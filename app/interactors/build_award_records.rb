class BuildAwardRecords
  include Interactor

  # rubocop:disable Metrics/CyclomaticComplexity
  def call
    award_params = context.award_params
    total_tokens_issued = context.total_tokens_issued
    uid = award_params[:uid]
    issuer = context[:issuer]
    project = context[:project]
    context.fail!(message: 'missing uid or email') if uid.blank?
    context.fail!(message: 'missing total_tokens_issued') if total_tokens_issued.blank?

    award_type = AwardType.find_by(id: context.award_type_id)
    context.fail!(message: 'missing award type') unless award_type
    context.fail!(message: 'Not authorized') unless project.id == award_type.project_id
    if context.issuer != project.account && !award_type.community_awardable?
      context.fail!(message: 'Not authorized')
    end

    quantity = award_params[:quantity].presence || 1

    channel = Channel.find_by id: context.channel_id
    authentication = Authentication.includes(:account).find_by(uid: uid)

    confirm_token = nil
    if authentication
      account = authentication.account
    elsif channel
      account = create_account(context, channel)
    else
      confirm_token = SecureRandom.hex
      email = uid
    end
    account_id = account ? account.id : -1
    # TODO: could be done with a award_type.build_award_with_quantity variation of award_type.create_award_with_quantity
    award = Award.new(award_params.merge(
                        account_id: account_id,
                        issuer_id: issuer.id,
                        unit_amount: award_type.amount,
                        quantity: quantity,
                        email: email,
                        total_amount: award_type.amount * BigDecimal(quantity)
    ))
    award.confirm_token = confirm_token
    award.award_type = award_type
    award.channel = channel

    # TODO: this should be an award validation
    unless award.total_amount + total_tokens_issued <= project.maximum_tokens
      context.fail!(message: "Sorry, you can't send more awards than the project's maximum number of allowable tokens")
    end

    if award.total_amount + project.total_month_awarded > project.maximum_royalties_per_month
      context.fail!(message: "Sorry, you can't send more awards this month than the project's maximum number of allowable tokens per month")
    end

    context.award = award
  end

  private

  def create_account(context, channel)
    uid = context.award_params[:uid]

    team = channel.team
    if team.discord?
      email = "#{uid}@discordapp.com"
    else
      response = Comakery::Slack.new(channel.authentication.token).get_user_info(uid)
      email = response.user.profile.email
      nickname = response.user.name
    end
    account = Account.find_or_create_by(email: email)
    account.nickname = nickname
    account.save
    context.fail!(message: account.errors.full_messages.join(', ')) unless account.valid?
    authentication = account.authentications.create(provider: team.provider, uid: uid)
    context.fail!(message: authentication.errors.full_messages.join(', ')) unless authentication.valid?
    channel.team.build_authentication_team authentication

    account
  end
end
