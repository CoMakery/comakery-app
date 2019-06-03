class Unsubscription < ApplicationRecord
  validates :email, presence: true
  validates :email, uniqueness: { message: 'Is Already Unsubscribed' }
end
