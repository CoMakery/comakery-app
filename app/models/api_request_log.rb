class ApiRequestLog < ApplicationRecord
  validates :ip, :body, presence: true
  validates :signature, presence: true, uniqueness: true
end
