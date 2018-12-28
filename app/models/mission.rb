class Mission < ApplicationRecord
  attachment :logo
  attachment :image

  belongs_to :token
  has_many :projects, inverse_of: :mission

  validates :name, :subtitle, :description, :logo, :image, presence: true
  validates :name, length: { maximum: 100 }
  validates :subtitle, length: { maximum: 140 }
  validates :description, length: { maximum: 250 }
  validate :validate_token_id

  def serialize
    self.as_json(only: %i[id name token_id subtitle description]).merge(
      logo_preview: self.logo.present? ? Refile.attachment_url(self, :logo, :fill, 150, 100) : nil,
      image_preview: self.image.present? ? Refile.attachment_url(self, :image, :fill, 100, 100) : nil
    )
  end

  private

  def validate_token_id
    errors.add(:token, 'is invalid') unless Token.exists?(token_id)
  end
end
