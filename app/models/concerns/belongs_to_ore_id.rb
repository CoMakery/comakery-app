module BelongsToOreId
  extend ActiveSupport::Concern

  included do
    before_validation :create_ore_id, on: :create
    before_validation :pending_for_ore_id, on: :create

    belongs_to :ore_id_account, optional: true
    validates :ore_id_account, presence: true, if: :ore_id?

    delegate :state, to: :ore_id_account, allow_nil: true

    private

      def create_ore_id
        self.ore_id_account = (account.ore_id_account || account.create_ore_id_account) if ore_id?
      end
  end
end
