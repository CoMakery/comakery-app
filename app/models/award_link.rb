class AwardLink < ApplicationRecord
  belongs_to :award_type
  has_one :owner, through: :award_type
  validates :award_type, :quantity, presence: true

  def link
    "#{ActionMailer::Base.asset_host}/receive_award/#{token}"
  end
end
