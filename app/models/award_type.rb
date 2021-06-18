class AwardType < ApplicationRecord
  include ActiveStorageValidator
  include PrepareImage

  belongs_to :project, touch: true
  has_many :awards, dependent: :restrict_with_error

  has_one_attached_and_prepare_image :diagram

  validates :project, presence: true
  validates :name, length: { maximum: 100 }
  validates :goal, length: { maximum: 250 }
  validates :description, length: { maximum: 750 }

  validate_image_attached :diagram

  after_create :switch_tasks_publicity
  after_save :switch_tasks_publicity, if: -> { saved_change_to_state? }

  enum state: { 'draft' => 0, 'invite only' => 1, 'public' => 2 }, _suffix: true

  private

    def switch_tasks_publicity
      case state
      when 'draft', 'invite only'
        awards.ready.where(account: nil).find_each { |a| a.update(status: :invite_ready) }
      when 'public'
        awards.invite_ready.each { |a| a.update(status: :ready) }
      end
    end
end
