class AwardType < ApplicationRecord
  belongs_to :project
  has_one :owner, through: :project, source: :owner_account
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
  has_many :award_links, dependent: :destroy
  validates :project, :name, :amount, presence: true
  validate :amount_didnt_change?, unless: :modifiable?
  validates :amount, numericality: { greater_than: 0 }

  scope :active, -> { where('award_types.disabled is null or award_types.disabled=false') }

  def self.invalid_params(attributes)
    attributes['name'].blank? || attributes['amount'].blank?
  end

  def modifiable?
    awards.count == 0
  end

  def amount_didnt_change?
    errors.add(:amount, :invalid, message: "can't be modified if there are existing awards") if amount != amount_was
  end

  # TODO: remove temporary migration method after migrating all environments
  def self.write_all_award_amounts
    AwardType.all.find_each(&:write_award_amount)
  end

  # TODO: remove temporary migration method after migrating all environments
  def write_award_amount
    # The find_each method uses find_in_batches with a batch size of 1000 (or as specified by the :batch_size option).
    # http://api.rubyonrails.org/classes/ActiveRecord/Batches.html
    awards.find_each do |award|
      award.update(unit_amount: amount, total_amount: award.quantity * amount)
    end
  end
end
