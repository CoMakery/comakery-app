class AwardType < ApplicationRecord
  belongs_to :project, touch: true
  belongs_to :specialty, optional: true
  has_many :awards, dependent: :restrict_with_error

  attachment :diagram, type: :image

  validates :project, presence: true
  validates :name, length: { maximum: 100 }
  validates :goal, length: { maximum: 250 }
  validates :description, length: { maximum: 750 }

  scope :matching_specialty_for, ->(account) { where(specialty_id: [account.specialty&.id, nil, 0]) }

  validate :specialty_changeable, if: -> { specialty_id_changed? && specialty_id_was.present? }

  private

    def specialty_changeable
      errors.add(:specialty_id, 'cannot be changed if batch has started tasks') if awards.where.not(status: :ready).present?
    end
end
