module Invitable
  extend ActiveSupport::Concern

  included do
    has_one :invite, as: :invitable, dependent: :destroy
    before_validation :populate_account

    def populate_account
      self.account ||= invite&.account
    end

    def invite_accepted
      populate_account
      save
    end
  end
end
