class ApiKey < ApplicationRecord
  belongs_to :api_authorizable, polymorphic: true
  before_validation :populate_key
  validates :key, presence: true, length: { is: 32 }
  validates :api_authorizable_id, uniqueness: { scope: :api_authorizable_type }

  private

    def populate_key
      self.key ||= SecureRandom.base64(24)
    end
end
