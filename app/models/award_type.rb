class AwardType < ActiveRecord::Base
  belongs_to :project
  has_many :awards, dependent: :restrict_with_exception do
    def create_with_quantity(quantity, issuer:, authentication:)
      award_type = @association.owner

      create quantity: quantity,
             unit_amount: award_type.amount,
             total_amount: (quantity * award_type.amount),
             issuer: issuer,
             authentication: authentication
    end
  end

  validates_presence_of :project, :name, :amount
  validate :amount_didnt_change?, unless: :modifiable?

  def self.invalid_params(attributes)
    attributes['name'].blank? || attributes['amount'].blank?
  end

  def modifiable?
    awards.count == 0
  end

  def amount_didnt_change?
    errors[:amount] = "can't be modified if there are existing awards" if amount_was != amount
  end

  # TODO: remove temporary migration method after migrating all environments
  def self.write_all_award_amounts
    AwardType.all.each { |award_type| award_type.write_award_amount }
  end

  # TODO: remove temporary migration method after migrating all environments
  def write_award_amount
    awards.each do |award|
      award.update(unit_amount: amount, total_amount: award.quantity * amount)
    end
  end
end
