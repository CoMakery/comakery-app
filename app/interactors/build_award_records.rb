class BuildAwardRecords
  include Interactor

  # rubocop:disable Metrics/CyclomaticComplexity
  def call
    award_params = context.award_params

    @award_type = AwardType.find_by(id: context.award_type_id)
    quantity = award_params[:quantity].presence || 1
    @total_amount = @award_type.amount * BigDecimal(quantity) if @award_type

    validate_data

    @channel = Channel.find_by id: context.channel_id
    account = make_account
    unless account
      confirm_token = SecureRandom.hex
      email = award_params[:uid]
    end

    award = Award.new(award_params.merge(account: account, issuer_id: context.issuer.id, unit_amount: @award_type.amount,
                                         quantity: quantity, email: email, total_amount: @total_amount))
    award.confirm_token = confirm_token
    award.award_type = @award_type
    award.channel = @channel

    context.award = award
  end

  private

  def validate_data
    context.fail!(message: 'missing uid or email') if context.award_params[:uid].blank?
    context.fail!(message: 'missing total_tokens_issued') if context.total_tokens_issued.blank?
    context.fail!(message: 'missing award type') unless @award_type
    context.fail!(message: 'Not authorized') unless context.project.id == @award_type.project_id
    if context.issuer != context.project.account && !@award_type.community_awardable?
      context.fail!(message: 'Not authorized')
    end
    unless @total_amount + context.total_tokens_issued <= context.project.maximum_tokens
      context.fail!(message: "Sorry, you can't send more awards than the project's maximum number of allowable tokens")
    end

    if @total_amount + context.project.total_month_awarded > context.project.maximum_royalties_per_month
      context.fail!(message: "Sorry, you can't send more awards this month than the project's maximum number of allowable tokens per month")
    end
  end

  def make_account
    authentication = Authentication.find_by(uid: context.award_params[:uid])
    if authentication
      account = authentication.account
    elsif @channel
      account = create_account
    end
    account
  end

  def create_account
    uid = context.award_params[:uid]

    team = @channel.team
    if team.discord?
      email = "#{uid}@discordapp.com"
      discord_client = Comakery::Discord.new
      info = discord_client.user_info(uid)
      nickname = info['username']
    else
      response = Comakery::Slack.new(@channel.authentication.token).get_user_info(uid)
      nickname = response.user.name
      email = response.user.profile.email || "#{uid}@slackbot.com"
    end
    account = Account.find_or_create_by(email: email)
    account.nickname = nickname
    account.save
    context.fail!(message: account.errors.full_messages.join(', ')) unless account.valid?
    authentication = account.authentications.create(provider: team.provider, uid: uid)
    context.fail!(message: authentication.errors.full_messages.join(', ')) unless authentication.valid?
    @channel.team.build_authentication_team authentication

    account
  end
end
