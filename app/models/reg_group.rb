class RegGroup < ApplicationRecord
  belongs_to :token
  has_many :account_token_records, dependent: :restrict_with_error
  has_many :accounts, through: :account_token_records, source: :account
  # rubocop:todo Rails/InverseOf
  has_many :sending_transfer_rules, class_name: 'TransferRule', foreign_key: 'sending_group_id', dependent: :restrict_with_error
  # rubocop:enable Rails/InverseOf
  # rubocop:todo Rails/InverseOf
  has_many :receiving_transfer_rules, class_name: 'TransferRule', foreign_key: 'receiving_group_id', dependent: :restrict_with_error
  # rubocop:enable Rails/InverseOf

  BLOCKCHAIN_ID_MAX = 2.pow(256) - 1
  BLOCKCHAIN_ID_MIN = 0

  validates_with ComakeryTokenValidator
  validates :name, :blockchain_id, presence: true
  validates :name, :blockchain_id, uniqueness: { scope: :token_id } # rubocop:todo Rails/UniqueValidationWithoutIndex
  validates :blockchain_id, inclusion: { in: BLOCKCHAIN_ID_MIN..BLOCKCHAIN_ID_MAX }

  before_validation :set_name

  def self.default_for(token)
    RegGroup.find_or_create_by!(token_id: token.id, blockchain_id: 0)
  end

  private

    def set_name
      self.name ||= blockchain_id.to_s
    end
end
