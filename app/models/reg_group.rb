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

  attr_readonly :blockchain_id

  validates_with SecurityTokenValidator
  validates :name, :blockchain_id, presence: true
  validates :name, :blockchain_id, uniqueness: { scope: :token_id } # rubocop:todo Rails/UniqueValidationWithoutIndex
  validates :blockchain_id, inclusion: { in: BLOCKCHAIN_ID_MIN..BLOCKCHAIN_ID_MAX }

  after_initialize :set_blockchain_id
  before_validation :set_name

  def self.default_for(token)
    RegGroup.find_or_create_by!(token_id: token.id, blockchain_id: token.token_type.default_reg_group)
  end

  private

    def set_blockchain_id
      return if blockchain_id
      return unless token_id

      last_blockchain_id = RegGroup.where(token_id: token_id).order(blockchain_id: :desc).first&.blockchain_id
      new_blockchain_id = last_blockchain_id + 1

      self.blockchain_id = new_blockchain_id || 0
    end

    def set_name
      self.name ||= blockchain_id.to_s
    end
end
