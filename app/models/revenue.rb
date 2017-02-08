class Revenue < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :amount, :currency, :project
  validates :currency, inclusion: { in: Comakery::Currency::DENOMINATIONS }
  validates_numericality_of :amount, greater_than: 0

  def self.total_amount
    sum(:amount)
  end
end