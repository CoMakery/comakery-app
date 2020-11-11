module BelongsToOreId
  extend ActiveSupport::Concern

  included do
    before_validation :create_ore_id, on: :create
    before_validation :pending_for_ore_id, on: :create
    before_destroy :abort_destroy_for_ore_id

    belongs_to :ore_id_account, optional: true
    validates :ore_id_account, presence: true, if: :ore_id?

    delegate :state, to: :ore_id_account, allow_nil: true

    def cannot_be_destroyed?
      ore_id?
    end

    private

      def create_ore_id
        self.ore_id_account = (account.ore_id_account || account.create_ore_id_account) if ore_id?
      end

      def abort_destroy_for_ore_id
        if cannot_be_destroyed?
          errors[:base] << 'An ORE ID wallet currently can not be removed'
          throw :abort
        end
      end
  end
end
