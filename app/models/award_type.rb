class AwardType < ApplicationRecord
  belongs_to :project, touch: true
  has_many :awards, dependent: :restrict_with_error

  attachment :diagram, type: :image

  validates :project, presence: true
  validates :name, length: { maximum: 100 }
  validates :goal, length: { maximum: 250 }
  validates :description, length: { maximum: 750 }

  after_save :switch_tasks_publicity, if: -> { saved_change_to_published? }
  after_create :switch_tasks_publicity

  private

    def switch_tasks_publicity
      if published?
        awards.unpublished.each { |a| a.update(status: :ready) }
      else
        awards.ready.each { |a| a.update(status: :unpublished) }
      end
    end
end
