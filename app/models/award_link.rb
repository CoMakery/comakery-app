class AwardLink < ApplicationRecord
  belongs_to :award_type

  validates :award_type, :quantity, presence: true

  def link
    "#{ActionMailer::Base.asset_host}/get_award/#{token}"
  end
end
