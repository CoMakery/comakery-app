class Interest < ApplicationRecord
  belongs_to :account
  belongs_to :project, counter_cache: true
  belongs_to :specialty

  validates :project_id, uniqueness: { scope: %i[account_id specialty_id protocol], message: 'has already been followed' }
end
