class OreId < ApplicationRecord
  belongs_to :account
  has_one :wallet, dependent: :destroy
end
