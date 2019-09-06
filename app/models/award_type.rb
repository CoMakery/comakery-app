class AwardType < ApplicationRecord
  belongs_to :project, touch: true
  has_many :awards, dependent: :restrict_with_error

  attachment :diagram, type: :image

  validates :project, presence: true
  validates :name, length: { maximum: 100 }
  validates :goal, length: { maximum: 250 }
  validates :description, length: { maximum: 750 }

  after_create :switch_tasks_publicity
  after_save :switch_tasks_publicity, if: -> { saved_change_to_state? }

  enum state: %i[draft pending ready]

  private

    def switch_tasks_publicity
      case state
      when 'draft', 'pending'
        awards.ready.where(account: nil).find_each { |a| a.update(status: :unpublished) }
      when 'ready'
        awards.unpublished.each { |a| a.update(status: :ready) }
      end
    end
end
