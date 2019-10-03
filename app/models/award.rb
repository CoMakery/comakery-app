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

  STARTED_TASKS_PER_CONTRIBUTOR = 5

  attachment :image, type: :image
  attachment :submission_image, type: :image

  attribute :specialty_id, :integer, default: -> { Specialty.default.id }

  belongs_to :account, optional: true, touch: true
  belongs_to :authentication, optional: true
  belongs_to :award_type, touch: true
  belongs_to :issuer, class_name: 'Account', touch: true
  belongs_to :channel, optional: true
  belongs_to :specialty
  belongs_to :cloned_from, class_name: 'Award', foreign_key: 'cloned_on_assignment_from_id', counter_cache: :assignments_count, touch: true
  has_many :assignments, class_name: 'Award', foreign_key: 'cloned_on_assignment_from_id'
  has_one :team, through: :channel
  has_one :project, through: :award_type
  has_one :token, through: :project

  validates :proof_id, :award_type, :name, :why, :requirements, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :quantity, numericality: { greater_than: 0 }, allow_nil: true
  validates :number_of_assignments, :number_of_assignments_per_user, numericality: { greater_than: 0 }
  validates :number_of_assignments_per_user, numericality: { less_than_or_equal_to: :number_of_assignments }
  validates :ethereum_transaction_address, ethereum_address: { type: :transaction, immutable: true }, if: -> { project&.coin_type_on_ethereum? } # see EthereumAddressable
  validates :ethereum_transaction_address, qtum_transaction_address: { immutable: true }, if: -> { project&.coin_type_on_qtum? }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
  validates :name, length: { maximum: 100 }
  validates :why, length: { maximum: 500 }
  validates :description, length: { maximum: 500 }
  validates :message, length: { maximum: 150 }
  validates :requirements, length: { maximum: 1000 }
  validates :proof_link, length: { maximum: 150 }
  validates :proof_link, exclusion: { in: %w[http:// https://], message: 'is not valid URL' }
  validates :proof_link, format: { with: URI.regexp(%w[http https]), message: 'must include protocol (e.g. https://)' }, if: -> { proof_link.present? }
  validates :submission_url, exclusion: { in: %w[http:// https://], message: 'is not valid URL' }
  validates :submission_url, format: { with: URI.regexp(%w[http https]), message: 'must include protocol (e.g. https://)' }, if: -> { submission_url.present? }
  validates :experience_level, inclusion: { in: EXPERIENCE_LEVELS.values }, allow_nil: true
  validates :submission_comment, presence: true, if: -> { status == 'submitted' }
  validates :expires_in_days, presence: true, numericality: { greater_than: 0 }

  validate :total_amount_fits_into_project_budget
  validate :contributor_doesnt_have_too_many_started_tasks, if: -> { status == 'started' }
  validate :contributor_doesnt_reach_maximum_assignments, if: -> { status == 'started' }

  before_validation :ensure_proof_id_exists
  before_validation :calculate_total_amount
  before_validation :set_paid_status_if_project_has_no_token, if: -> { status == 'accepted' && !project.token }
  before_validation :make_unpublished_if_award_type_is_not_ready, if: -> { status == 'ready' && !award_type&.ready? }
  before_validation :store_license_hash, if: -> { status == 'started' && agreed_to_license_hash.nil? }
  before_validation :set_expires_at, if: -> { status == 'started' && expires_at.nil? }
  before_validation :clear_expires_at, if: -> { status == 'submitted' && expires_at.present? }
  before_destroy :abort_destroy
  after_save :update_account_experience, if: -> { completed? }

  scope :completed, -> { where 'awards.status in(3,5)' }
  scope :listed, -> { where 'awards.status not in(6,7)' }
  scope :in_progress, -> { where 'awards.status in(0,1,2,3)' }
  scope :contributed, -> { where 'awards.status in(1,2,3,4,5)' }

  scope :filtered_for_view, lambda { |filter, account|
    case filter
    when 'ready'
      where(status: :ready, account: [nil, account])
    when 'started'
      where(status: :started).where(account: account)
    when 'submitted'
      where(status: %i[submitted accepted], account: account)
    when 'to review'
      where(status: :submitted).where(award_type: account.admin_award_types + account.award_types)
    when 'to pay'
      where(status: :accepted).where(award_type: account.admin_award_types + account.award_types)
    when 'done'
      where(status: %i[paid rejected], account: account).or(where(status: %i[paid rejected], award_type: account.admin_award_types + account.award_types))
    else
      none
    end
  }

  enum status: %i[ready started submitted accepted rejected paid cancelled unpublished]

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

  def matching_experience_for?(account)
    experience_level.to_i <= account.experience_for(specialty)
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

  def can_be_edited?
    (ready? || unpublished?) && !cloned? && !any_clones?
  end

  def can_be_assigned?
    (ready? || unpublished?)
  end

  def cloned?
    cloned_on_assignment_from_id.present?
  end

  def any_clones?
    !assignments.empty?
  end

  def cloneable?
    number_of_assignments.to_i > 1
  end

  def should_be_cloned?
    assignments.size + 1 < number_of_assignments.to_i
  end

  def can_be_cloned_for?(account)
    (account.awards.started.count < STARTED_TASKS_PER_CONTRIBUTOR) && !reached_maximum_assignments_for?(account)
  end

  def reached_maximum_assignments_for?(account)
    assignments.where(account: account).size >= number_of_assignments_per_user.to_i
  end

  def clone_on_assignment
    new_award = dup
    new_award.cloned_on_assignment_from_id = id
    new_award.number_of_assignments = 1
    new_award.number_of_assignments_per_user = 1
    new_award.save!
    new_award
  end

  def possible_quantity
    if cancelled? || rejected?
      BigDecimal(0)
    else
      (number_of_assignments || 1) - assignments.size
    end
  end

  def possible_total_amount
    if cancelled? || rejected?
      BigDecimal(0)
    else
      total_amount * possible_quantity
    end
  end

  def expire!
    if cloned?
      self.status = :cancelled
    else
      self.status = :ready
      self.expires_at = nil
      self.account = nil
    end

    save
  end

  def expiring_notification_sent
    update(notify_on_expiration_at: nil)
  end

  def run_expiration
    if started? && expires_at && (expires_at < Time.current)
      begin
        TaskMailer.with(award: self).task_expired_for_account.deliver_now
        TaskMailer.with(award: self).task_expired_for_issuer.deliver_now
      ensure
        expire!
      end
    end
  end

  def run_expiring_notification
    if started? && notify_on_expiration_at && (notify_on_expiration_at < Time.current)
      begin
        TaskMailer.with(award: self).task_expiring.deliver_now
      ensure
        expiring_notification_sent
      end
    end
  end

  delegate :image, to: :team, prefix: true, allow_nil: true

  private

    def calculate_total_amount
      self.total_amount = BigDecimal(amount || 0) * BigDecimal(quantity || 1)
    end

    def set_paid_status_if_project_has_no_token
      self.status = 'paid'
    end

    def make_unpublished_if_award_type_is_not_ready
      self.status = 'unpublished'
    end

    def total_amount_fits_into_project_budget
      return if project&.maximum_tokens.nil? || project&.maximum_tokens&.zero?

      if possible_total_amount + BigDecimal(project&.awards&.where&.not(id: id)&.sum(&:possible_total_amount) || 0) > BigDecimal(project&.maximum_tokens)
        errors[:base] << "Sorry, you can't exceed the project's budget"
      end
    end

    def abort_destroy
      unless can_be_edited?
        errors[:base] << "#{status.capitalize} task can't be deleted"
        throw :abort
      end
    end

    def contributor_doesnt_have_too_many_started_tasks
      if account && account.awards.started.count >= STARTED_TASKS_PER_CONTRIBUTOR
        errors.add(:base, "Sorry, you can't start more than #{STARTED_TASKS_PER_CONTRIBUTOR} tasks")
      end
    end

    def contributor_doesnt_reach_maximum_assignments
      if account && reached_maximum_assignments_for?(account)
        errors.add(:base, 'Sorry, you already did the task maximum times allowed')
      end
    end

    def update_account_experience
      Experience.increment_for(account, specialty)
    end

    def store_license_hash
      self.agreed_to_license_hash = project.agreed_to_license_hash
    end

    def set_expires_at
      self.updated_at = Time.current
      self.expires_at = expires_in_days.days.since(updated_at)
      self.notify_on_expiration_at = (expires_in_days.days * 0.75).since(updated_at)
    end

    def clear_expires_at
      self.expires_at = nil
      self.notify_on_expiration_at = nil
    end
end
