class Payment < ActiveRecord::Base
  nilify_blanks

  belongs_to :project
  belongs_to :issuer, class_name: Authentication
  belongs_to :payee, class_name: Authentication

  validates_presence_of :project, :payee, :total_value, :share_value, :quantity_redeemed

  def status
    "unpaid"
  end
end
