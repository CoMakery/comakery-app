class ProjectRole < ApplicationRecord
  belongs_to :account
  belongs_to :project

  validates :project_id, uniqueness: { scope: %i[account_id], message: 'already has a role in project' }

  enum role: { interested: 0, admin: 1, observer: 2 }
end
