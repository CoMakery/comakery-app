# == Schema Information
#
# Table name: account_roles
#
#  account_id :integer          not null
#  created_at :datetime
#  id         :integer          not null, primary key
#  role_id    :integer          not null
#  updated_at :datetime
#
# Indexes
#
#  index_account_roles_on_account_id_and_role_id  (account_id,role_id) UNIQUE
#

class AccountRole < ActiveRecord::Base
  belongs_to :account
  belongs_to :role

  validates :account, :role, presence: true
end
