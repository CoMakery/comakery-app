class Revenue < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :amount, :currency, :project

  validates_numericality_of :amount, greater_than: 0
end