class RegGroup < ApplicationRecord
  belongs_to :token
  has_many :account_token_records
  has_many :accounts, through: :account_token_records, source: :account
  has_many :sending_transfer_rules, class_name: 'TransferRule', foreign_key: 'sending_group_id'
  has_many :receiving_transfer_rules, class_name: 'TransferRule', foreign_key: 'receiving_group_id'

  validates_with ComakeryTokenValidator
  validates :name, :blockchain_id, presence: true
  validates :name, :blockchain_id, uniqueness: { scope: :token_id }

  before_validation :set_name

  private

   def set_name
     self.name ||= blockchain_id.to_s
   end
end
