class AwardType < ApplicationRecord
  belongs_to :project, touch: true
  belongs_to :specialty
  has_many :awards

  attachment :diagram, type: :image

  validates :project, :specialty, presence: true
  validates :name, length: { maximum: 100 }
  validates :goal, length: { maximum: 250 }
  validates :description, length: { maximum: 750 }
end
