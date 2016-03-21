class AwardType < ActiveRecord::Base
  belongs_to :project
  has_many :awards, dependent: :restrict_with_exception

  validates_presence_of :project, :name, :amount
  validate :amount, :amount_didnt_change?, unless: :modifiable?

  def self.invalid_params(attributes)
    attributes['name'].blank? || attributes['amount'].blank?
  end

  def modifiable?
    awards.count == 0
  end

  def amount_didnt_change?
    errors[:amount] = "can't be modified if there are existing awards" if amount_was != amount
  end
end
