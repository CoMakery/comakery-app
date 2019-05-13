require 'bigdecimal'

class Award < ApplicationRecord
  paginates_per 50

  include EthereumAddressable
  include QtumTransactionAddressable

  EXPERIENCE_LEVELS = {
    'New Contributor' => 0,
    'Demonstrated Skills' => 3,
    'Established Contributor' => 10
  }.freeze

  attachment :image, type: :image

  belongs_to :account, optional: true
  belongs_to :authentication, optional: true
  belongs_to :award_type
  belongs_to :issuer, class_name: 'Account'
  belongs_to :channel, optional: true
  has_one :team, through: :channel
  has_one :project, through: :award_type
  has_one :token, through: :project

  validates :proof_id, :award_type, :name, :why, :description, :requirements, :proof_link, presence: true
  validates :amount, :total_amount, numericality: { greater_than: 0 }
  validates :quantity, numericality: { greater_than: 0 }, allow_nil: true
  validates :ethereum_transaction_address, ethereum_address: { type: :transaction, immutable: true }, if: -> { project&.coin_type_on_ethereum? } # see EthereumAddressable
  validates :ethereum_transaction_address, qtum_transaction_address: { immutable: true }, if: -> { project&.coin_type_on_qtum? }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
  validates :name, length: { maximum: 100 }
  validates :why, length: { maximum: 500 }
  validates :description, length: { maximum: 500 }
  validates :message, length: { maximum: 150 }
  validates :requirements, length: { maximum: 750 }
  validates :proof_link, length: { maximum: 150 }
  validates :proof_link, exclusion: { in: %w[http:// https://], message: 'is not valid URL' }
  validates :proof_link, format: { with: URI.regexp(%w[http https]), message: 'must include protocol (e.g. https://)' }
  validates :experience_level, inclusion: { in: EXPERIENCE_LEVELS.values }, allow_nil: true

  validate :total_amount_fits_into_project_budget

  before_validation :ensure_proof_id_exists
  before_validation :calculate_total_amount
  before_destroy :abort_destroy

  scope :completed, -> { where 'awards.status in(3,5)' }
  scope :listed, -> { where 'awards.status not in(6)' }

  enum status: %i[ready started submitted accepted rejected paid cancelled]

  def self.total_awarded
    completed.sum(:total_amount)
  end

  def ensure_proof_id_exists
    self.proof_id ||= SecureRandom.base58(44) # 58^44 > 2^256
  end

  def ethereum_issue_ready?
    project.token.ethereum_enabled && project.token.coin_type_on_ethereum? &&
      account&.ethereum_wallet.present? &&
      ethereum_transaction_address.blank?
  end

  def self_issued?
    account_id == issuer_id
  end

  def amount_to_send
    if project.decimal_places_value.to_i.positive?
      (total_amount * project.decimal_places_value.to_i).to_i
    else
      total_amount.to_i
    end
  end

  def recipient_auth_team
    account.authentication_teams.find_by team_id: channel.team_id if channel
  end

  def send_confirm_email
    unless channel
      if confirmed?
        UserMailer.incoming_award_notifications(self).deliver_now
      else
        UserMailer.send_award_notifications(self).deliver_now
      end
    end
  end

  def discord_client
    @discord_client ||= Comakery::Discord.new
  end

  def slack_client
    auth_team = team.authentication_team_by_account issuer
    token = auth_team.authentication.token
    Comakery::Slack.get(token)
  end

  def send_award_notifications
    return unless channel
    if team.discord?
      discord_client.send_message self
    else
      slack_client.send_award_notifications(award: self)
    end
  end

  def confirm!(account)
    update confirm_token: nil, account: account
  end

  def confirmed?
    confirm_token.blank?
  end

  def discord?
    team && team.discord?
  end

  def completed?
    %w[accepted paid].include? status
  end

  def can_be_deleted?
    status == 'ready'
  end

  delegate :image, to: :team, prefix: true, allow_nil: true

  private

    def calculate_total_amount
      self.total_amount = BigDecimal(amount || 0) * BigDecimal(quantity || 1)
    end

    def total_amount_fits_into_project_budget
      return if project&.maximum_tokens.nil? || project&.maximum_tokens&.zero?
      if total_amount + BigDecimal(project&.awards&.where&.not(id: id)&.sum(:total_amount) || 0) > BigDecimal(project&.maximum_tokens)
        errors[:base] << "Sorry, you can't send more awards than the project's budget"
      end
    end

    def abort_destroy
      unless can_be_deleted?
        errors[:base] << "#{status.capitalize} task can't be deleted"
        throw :abort
      end
    end
end
