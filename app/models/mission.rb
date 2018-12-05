class Mission < ApplicationRecord
  attachment :logo
  attachment :image
  validates :name, :subtitle, :description, :logo, :image, presence: true
end
