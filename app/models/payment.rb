class Payment < ActiveRecord::Base
  nilify_blanks

  belongs_to :project
  belongs_to :issuer, class_name: Account
  belongs_to :recipient, class_name: Authentication

  validates_presence_of :project, :issuer, :recipient, :amount

end
