class SendInvite
  include Interactor

  def call
    context.fail!(errors: ['The user must have signed up to add them']) if account.blank?

    invite = context.project.interests.new(account: account, role: context.params[:role])

    context.fail!(errors: invite.errors.full_messages) unless invite.save
  end

  private

    def account
      Account.find_by(email: context.params[:email])
    end
end
