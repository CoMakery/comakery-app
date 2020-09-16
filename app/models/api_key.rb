class ApiKey < ApplicationRecord
  belongs_to :api_authorizable, polymorphic: true
  before_validation :populate_key
  validates :key, presence: true, length: { is: 32 }
  # rubocop:todo Rails/UniqueValidationWithoutIndex
  validates :api_authorizable_id, uniqueness: { scope: :api_authorizable_type }
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  private

    def populate_key
      self.key ||= SecureRandom.base64(24)
    end
end
