class SendAward
  include Interactor

  def call
    context.fail!(message: 'Missing username or email') if context.uid.blank? && context.email.blank?

    context.channel = Channel.find_by id: context.channel_id
    account = find_or_create_account
    email, confirm_token = account ? [nil, nil] : [context.email, SecureRandom.hex]

    unless context.award.update(
      account: account,
      email: email,
      confirm_token: confirm_token,
      channel: context.channel,
      quantity: context.quantity,
      message: context.message,
      status: 'done'
    )
      context.fail!(message: context.award.errors.full_messages.join(', '))
    end
  end

  private

  def find_or_create_account
    account = Account.where('lower(email)=?', context.email&.downcase).first
    account, errors = Account.find_or_create_for_authentication(context.uid, context.channel) unless account
    return unless account
    context.fail!(message: errors) if errors.present?
    account
  end
end
