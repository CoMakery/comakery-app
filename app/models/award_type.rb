class AwardType < ApplicationRecord
  belongs_to :project, touch: true
  has_many :awards, dependent: :restrict_with_error

  attachment :diagram, type: :image

  validates :project, presence: true
  validates :name, length: { maximum: 100 }
  validates :goal, length: { maximum: 250 }
  validates :description, length: { maximum: 750 }
end
