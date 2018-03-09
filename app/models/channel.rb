class Channel < ApplicationRecord
  belongs_to :project
  belongs_to :team

  delegate :provider, to: :project
  validates :name, :team_id, :project, presence: true
end
