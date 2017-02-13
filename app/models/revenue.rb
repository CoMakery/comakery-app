class Revenue < ActiveRecord::Base
  belongs_to :project
  belongs_to :recorded_by, class_name: Account

  validates_presence_of :amount, :currency, :project, :recorded_by
  validates :currency, inclusion: { in: Comakery::Currency::DENOMINATIONS }
  validates_numericality_of :amount, greater_than: 0

  def self.total_amount
    sum(:amount)
  end

  def amount=(x)
    x.sub!(',','') if x.respond_to?(:sub)
    write_attribute(:amount, x)
  end

  def issuer_slack_icon
    recorded_by&.slack_auth&.slack_icon
  end

  def issuer_display_name
    recorded_by&.slack_auth&.display_name
  end
end