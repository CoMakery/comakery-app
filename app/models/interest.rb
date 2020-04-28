class Interest < ApplicationRecord
  belongs_to :account
  belongs_to :project, counter_cache: true
  belongs_to :specialty

  validates :project_id, uniqueness: { scope: %i[account_id specialty_id protocol], message: 'has already been followed' }

  before_destroy do
    if project.admins.include?(account) || project.account == account
      errors.add(:project, 'cannot be unfollowed by an admin')
      throw :abort
    end
  end
end
