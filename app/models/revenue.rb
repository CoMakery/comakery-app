class Revenue < ActiveRecord::Base
  belongs_to :project
  belongs_to :recorded_by, class_name: Account

  validates_presence_of :amount, :currency, :project, :recorded_by
  validates :currency, inclusion: {in: Comakery::Currency::DENOMINATIONS.keys}
  validates_numericality_of :amount, greater_than: 0
  validate :amount_must_use_the_precision_of_the_currency

  def self.total_amount
    sum(:amount)
  end

  def amount=(x)
    x.gsub!(',', '') if x.respond_to?(:sub!)
    write_attribute(:amount, x)
  end

  def issuer_slack_icon
    recorded_by&.slack_auth&.slack_icon
  end

  def issuer_display_name
    recorded_by&.slack_auth&.display_name
  end

  private

  def amount_must_use_the_precision_of_the_currency
    return if amount.nil? || amount_currency_precision.nil?
    if amount.truncate(amount_currency_precision) != amount
      errors.add(:amount, "must use only #{amount_currency_precision} decimal places for #{currency}")
    end
  end

  def amount_currency_precision
    Comakery::Currency::PRECISION[currency]
  end
end