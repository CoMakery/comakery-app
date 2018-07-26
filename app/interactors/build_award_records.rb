class BuildAwardRecords
  include Interactor

  # rubocop:disable Metrics/CyclomaticComplexity
  def call
    context.award_type = AwardType.find_by(id: context.award_type_id)
    context.total_amount = context.award_type.amount * BigDecimal(context.quantity) if context.award_type && context.quantity

    validate_data

    context.channel = Channel.find_by id: context.channel_id
    account = find_or_create_account
    unless account
      confirm_token = SecureRandom.hex
      email = context.uid
    end

    context.award = Award.new(account: account, issuer_id: context.issuer.id, unit_amount: context.award_type.amount, description: context.description,
                              quantity: context.quantity, email: email, total_amount: context.total_amount, confirm_token: confirm_token,
                              award_type: context.award_type, channel: context.channel)
  end

  private

  def validate_data
    context.fail!(message: 'missing award type') unless context.award_type
    context.fail!(message: 'Not authorized') unless context.project.id == context.award_type.project_id
    if context.issuer != context.project.account && !context.award_type.community_awardable?
      context.fail!(message: 'Not authorized')
    end
    context.fail!(message: 'quantity must greater than 0') if context.quantity.blank?
    context.fail!(message: 'missing uid or email') if context.uid.blank?
    context.fail!(message: 'missing total_tokens_issued') if context.total_tokens_issued.blank?

    if context.total_amount + context.total_tokens_issued > context.project.maximum_tokens
      context.fail!(message: "Sorry, you can't send more awards than the project's maximum number of allowable tokens")
    end

    if context.total_amount + context.project.total_month_awarded > context.project.maximum_royalties_per_month
      context.fail!(message: "Sorry, you can't send more awards this month than the project's maximum number of allowable tokens per month")
    end
  end

  def find_or_create_account
    account = Account.find_by email: context.uid
    account, errors = Account.find_or_create_for_authentication(context.uid, context.channel) unless account
    return unless account
    context.fail!(message: errors) if errors.present?
    account
  end
end
