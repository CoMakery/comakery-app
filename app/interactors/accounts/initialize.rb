module Accounts
  class Initialize
    include Interactor

    def call
      account = begin
        if context.whitelabel_mission
          context.whitelabel_mission.managed_accounts.new(context.account_params)
        else
          Account.new(context.account_params)
        end
      end

      account.email_confirm_token = SecureRandom.hex
      account.password_required = true
      account.name_required = false
      account.agreement_required = context.whitelabel_mission ? false : true
      account.agreed_to_user_agreement = agreed_to_user_agreement

      context.account = account
    end

    private

      def agreed_to_user_agreement
        if context.account_params[:agreed_to_user_agreement] == '0'
          nil
        else
          Date.current
        end
      end
  end
end
