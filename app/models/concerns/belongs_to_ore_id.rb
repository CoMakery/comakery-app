module BelongsToOreId
  extend ActiveSupport::Concern

  included do
    before_validation :create_ore_id, on: :create
    before_validation :pending_for_ore_id, on: :create

    belongs_to :ore_id, optional: true
    validates :ore_id_id, presence: true, if: :ore_id?

    def ore_id_password_reset_url(redirect_url)
      return unless ore_id?

      "https://example.org?redirect=#{redirect_url}"
    end

    private

      def create_ore_id
        self.ore_id = account.ore_ids.create if ore_id?
      end

      def pending_for_ore_id
        self.state = :pending if ore_id?
      end
  end
end
