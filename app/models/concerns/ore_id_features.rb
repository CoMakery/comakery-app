module OreIdFeatures
  extend ActiveSupport::Concern

  included do
    before_validation :pending_for_ore_id, on: :create

    def ore_id_password_reset_url(redirect_url)
      return unless ore_id?

      "https://example.org?redirect=#{redirect_url}"
    end

    private

      def pending_for_ore_id
        self.state = :pending if ore_id?
      end
  end
end
