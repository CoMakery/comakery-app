class AwardLink < ApplicationRecord
  belongs_to :award_type
  has_one :owner, through: :award_type
  validates :award_type, :quantity, presence: true

  def link
    "#{ActionMailer::Base.asset_host}/receive_award/#{token}"
  end

  def display_status
    return 'received' if status == 'received'
    return 'expired' if created_at < Time.zone.today - 7.days
    status
  end

  def available?
    display_status == 'available'
  end
end
