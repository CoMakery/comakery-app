class Payment < ActiveRecord::Base
  nilify_blanks

  belongs_to :project
  belongs_to :issuer, class_name: Authentication
  belongs_to :payee, class_name: Authentication

  validates_presence_of :project, :payee, :total_value, :share_value, :quantity_redeemed
  validates_numericality_of :quantity_redeemed, :total_value, greater_than_or_equal_to: 0
  validate :payee_has_the_awards_they_are_redeeming

  def status
    "unpaid"
  end

  private

  def payee_has_the_awards_they_are_redeeming
    return unless payee.present? && project.present? && quantity_redeemed.present?
    if quantity_redeemed > payee.total_awards_remaining(project)
      errors.add(:quantity_redeemed, "cannot be greater than the payee's total awards remaining balance")
    end
  end
end
