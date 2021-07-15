# Allow usage of has_and_belongs_to_many to avoid creating a separate model for accounts_projects join table:
# rubocop:disable Rails/HasAndBelongsToMany

class Project < ApplicationRecord
  include ApiAuthorizable
  include PrepareImage

  nilify_blanks

  has_one_attached_and_prepare_image :image
  has_one_attached_and_prepare_image :square_image
  has_one_attached_and_prepare_image :panoramic_image
  has_one_attached :transfers_csv

  belongs_to :account, touch: true
  has_one :hot_wallet, class_name: 'Wallet', touch: true, dependent: :destroy
  has_and_belongs_to_many :admins, class_name: 'Account'
  belongs_to :mission, optional: true, touch: true
  belongs_to :token, optional: true, touch: true

  has_many :interests # rubocop:todo Rails/HasManyOrHasOneDependent
  has_many :interested, -> { distinct }, through: :interests, source: :account
  has_many :project_roles, dependent: :destroy
  has_many :accounts, through: :project_roles, source: :account
  has_many :project_admins, -> { where(project_roles: { role: :admin }) }, through: :project_roles, source: :account
  has_many :project_interested, -> { where(project_roles: { role: :interested }) }, through: :project_roles, source: :account
  has_many :project_observers, -> { where(project_roles: { role: :observer }) }, through: :project_roles, source: :account

  has_many :account_token_records, ->(project) { where token_id: project.token_id }, through: :accounts, source: :account_token_records
  has_many :transfer_rules, through: :token
  has_many :transfer_types, dependent: :destroy
  has_many :award_types, inverse_of: :project, dependent: :destroy
  # rubocop:todo Rails/InverseOf
  has_many :ready_award_types, -> { where state: 'public' }, source: :award_types, class_name: 'AwardType'
  # rubocop:enable Rails/InverseOf
  has_many :awards, through: :award_types, dependent: :destroy
  has_many :published_awards, through: :ready_award_types, source: :awards, class_name: 'Award'
  has_many :completed_awards, -> { where.not ethereum_transaction_address: nil }, through: :award_types, source: :awards
  has_many :blockchain_transactions, through: :token
  has_many :channels, -> { order :created_at }, inverse_of: :project, dependent: :destroy

  has_many :contributors, through: :awards, source: :account # TODO: deprecate in favor of contributors_distinct
  has_many :contributors_distinct, -> { distinct }, through: :awards, source: :account
  has_many :teams, through: :account

  accepts_nested_attributes_for :channels, reject_if: :invalid_channel, allow_destroy: true

  enum payment_type: {
    project_token: 1
  }
  enum visibility: { member: 0, public_listed: 1, member_unlisted: 2, public_unlisted: 3, archived: 4 }
  enum status: { active: 0, passive: 1 }
  enum hot_wallet_mode: { disabled: 0, auto_sending: 1, manual_sending: 2 }, _prefix: :hot_wallet

  validates :description, :account, :title, presence: true
  validates :long_id, presence: { message: "identifier can't be blank" }
  # rubocop:todo Rails/UniqueValidationWithoutIndex
  validates :long_id, uniqueness: { message: "identifier can't be blank or not unique" }
  # rubocop:enable Rails/UniqueValidationWithoutIndex
  validates :maximum_tokens, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :transfer_batch_size, numericality: { greater_than: 0, less_than_or_equal_to: 250, only_integer: true }
  validate :valid_tracker_url, if: -> { tracker.present? }
  validate :valid_contributor_agreement_url, if: -> { contributor_agreement_url.present? }
  validate :valid_video_url, if: -> { video_url.present? }
  validate :token_changeable, if: -> { token_id_changed? && token_id_was.present? }
  validate :terms_should_be_readonly, if: -> { legal_project_owner_changed? || exclusive_contributions_changed? || confidentiality_changed? }

  before_validation :set_whitelabel, if: -> { mission }
  before_validation :store_license_hash, if: -> { !terms_readonly? && !whitelabel? }
  after_save :udpate_awards_if_token_was_added, if: -> { saved_change_to_token_id? && token_id_before_last_save.nil? }
  after_create :add_owner_as_admin
  after_create :create_default_transfer_types
  after_update_commit :broadcast_hot_wallet_mode, if: :saved_change_to_hot_wallet_mode?
  after_update_commit :broadcast_batch_size, if: :saved_change_to_transfer_batch_size?

  scope :featured, -> { order :featured }
  scope :unlisted, -> { where(visibility: %i[member_unlisted public_unlisted]) }
  scope :listed, -> { where.not(visibility: %i[member_unlisted public_unlisted]) }
  scope :visible, -> { where(visibility: %i[member public_listed]) }
  scope :unarchived, -> { where.not(visibility: :archived) }
  scope :publics, -> { where(visibility: :public_listed) }
  scope :with_all_attached_images, -> { with_attached_image.with_attached_square_image.with_attached_panoramic_image }
  scope :non_confidential, -> { where(require_confidentiality: false) }

  delegate :_token_type, to: :token, allow_nil: true
  delegate :_token_type_on_ethereum?, to: :token, allow_nil: true
  delegate :_token_type_on_qtum?, to: :token, allow_nil: true
  delegate :total_awarded, to: :awards, allow_nil: true

  validates :github_url, format: { with: %r{\Ahttps?:\/\/(www\.)?github\.com\/..*\z} }, allow_blank: true
  validates_url :documentation_url, :getting_started_url, :governance_url, :funding_url, :video_conference_url, allow_blank: true
  validates_each :github_url, :documentation_url, :getting_started_url, :governance_url, :funding_url, :video_conference_url, allow_blank: true do |record, attr, value|
    record.errors.add(attr, 'is unsafe') if ApplicationController.helpers.sanitize(value) != value
  end

  def self.assign_project_owner_from(project_or_project_id, email)
    project = project_or_project_id.is_a?(Integer) ? Project.find(project_or_project_id) : project_or_project_id
    raise ArgumentError, 'Project data is invalid' if project.invalid?

    new_owner = Account.find_by(email: email)
    raise ArgumentError, 'Could not find an Account with that email address' if new_owner.blank?

    previous_owner = project.account
    project.project_roles.find_by(account: previous_owner).update(role: :admin)
    project.account_id = new_owner.id
    project.project_roles.find_or_create_by(account: new_owner).update(role: :admin)
    project.save!
  end

  def assign_project_owner_from(email)
    self.class.assign_project_owner_from(self, email)
  end

  def safe_add_admin(new_admin)
    project_admins << new_admin unless project_admins.exists?(new_admin.id)
  end

  def add_account(account)
    accounts << account unless account.involved?(id)
  end

  def top_contributors
    Account
      .with_attached_image
      .select('accounts.*, sum(a1.total_amount) as total_awarded, max(a1.created_at) as last_awarded_at').joins("
      left join awards a1 on a1.account_id=accounts.id and a1.status in(3,5)
      left join award_types on a1.award_type_id=award_types.id
      left join projects on award_types.project_id=projects.id")
      .where('projects.id=?', id)
      .group('accounts.id')
      .order('total_awarded desc, last_awarded_at desc').includes(:specialty).first(5)
  end

  def total_month_awarded
    awards.completed.where('awards.created_at >= ?', Time.zone.today.beginning_of_month).sum(:total_amount)
  end

  def community_award_types
    award_types.where(community_awardable: true)
  end

  def invalid_channel(attributes)
    Channel.invalid_params(attributes)
  end

  def video_id
    # taken from http://stackoverflow.com/questions/5909121/converting-a-regular-youtube-link-into-an-embedded-video
    # Regex from http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
    # Vimeo regex from https://stackoverflow.com/questions/41208456/javascript-regex-vimeo-id

    case video_url
    when %r{youtu\.be/([^\?]*)}
      Regexp.last_match(1)
    when %r{^.*((v/)|(embed/)|(watch\?))\??v?=?([^\&\?]*).*}
      Regexp.last_match(5)
    when %r{(?:www\.|player\.)?vimeo.com/(?:channels/(?:\w+/)?|groups/(?:[^/]*)/videos/|album/(?:\d+)/video/|video/|)(\d+)([a-zA-Z0-9_\-]*)?}i
      Regexp.last_match(1)
    end
  end

  def show_id
    unlisted? ? long_id : id
  end

  def public?
    public_listed? || public_unlisted?
  end

  def unlisted?
    member_unlisted? || public_unlisted?
  end

  def percent_awarded
    return 0 if maximum_tokens.to_i.zero?

    total_awarded * 100.0 / maximum_tokens
  end

  def awards_for_chart(max: 1000) # rubocop:todo Metrics/CyclomaticComplexity
    result = []
    recents = awards.completed.includes(:account).limit(max).order('id desc')
    date_groups = recents.group_by { |a| a.created_at.strftime('%Y-%m-%d') }
    date_groups.delete(recents.first.created_at.strftime('%Y-%m-%d')) if awards.completed.count > max
    contributors = {}
    recents.map(&:account).uniq.each do |a|
      name = a&.decorate&.name || 'Others'
      contributors[name] = 0
    end
    date_groups.each do |group|
      item = {}
      item[:date] = group[0]
      item = item.merge(contributors)
      user_groups = group[1].group_by(&:account)
      user_groups.each do |ugroup|
        name = ugroup[0]&.decorate&.name || 'Others'
        item[name] = ugroup[1].sum(&:total_amount)
      end
      result << item
    end
    result
  end

  def ready_tasks_by_specialty(limit_per_specialty = 5)
    awards.ready.includes(:specialty, :project, :issuer, :account, :award_type).group_by(&:specialty).map { |specialty, awards| [specialty, awards.take(limit_per_specialty)] }.to_h
  end

  def stats
    {
      batches: ready_award_types.size,
      tasks: published_awards.in_progress.size,
      accounts: accounts.size
    }
  end

  def terms_readonly?
    awards.contributed.any?
  end

  def default_award_type
    award_types.find_or_create_by(name: 'Transfers', goal: '—', description: '—')
  end

  def supports_transfer_rules?
    token&.token_type&.operates_with_transfer_rules?
  end

  def create_default_transfer_types
    TransferType.create_defaults_for(self) if transfer_types.empty?
  end

  def download_transfers_csv
    update_transfers_csv

    transfers_csv.blob.download
  end

  def update_transfers_csv
    return unless should_update_transfers_csv?

    transfers_csv.attach(
      io: StringIO.new(transfers_to_csv),
      filename: 'transfers.csv',
      content_type: 'text/csv'
    )
  end

  def should_update_transfers_csv?
    return true unless transfers_csv.attached?
    return true if awards.completed.blank?

    transfers_csv.blob.created_at < awards.completed.maximum(:updated_at)
  end

  def transfers_to_csv
    return '' if awards.completed.blank?

    CSV.generate do |csv_file|
      csv_file << awards.last.decorate.to_csv_header

      awards.completed.find_each do |award|
        csv_file << award.decorate.to_csv
      end
    end
  end

  private

    def valid_tracker_url
      validate_url(:tracker)
    end

    def valid_contributor_agreement_url
      validate_url(:contributor_agreement_url)
    end

    def valid_video_url
      validate_url(:video_url)
      return if errors[:video_url].present?

      errors[:video_url] << 'must be a link to Youtube or Vimeo video' if video_id.blank?
    end

    def validate_url(attribute_name)
      uri = URI.parse(send(attribute_name) || '')
    rescue URI::InvalidURIError
      uri = nil
    ensure
      errors[attribute_name] << 'must be a valid url' unless uri&.absolute?
      uri
    end

    def token_changeable
      errors.add(:token_id, 'cannot be changed if project has completed tasks') if awards.completed.any?
    end

    def terms_should_be_readonly
      errors.add(:base, 'terms cannot be changed') if terms_readonly?
    end

    def udpate_awards_if_token_was_added
      awards.paid.each { |a| a.update(status: :accepted) }
    end

    def add_owner_as_admin
      project_admins << account unless account.involved?(id)
    end

    def store_license_hash
      # rubocop:todo Rails/FilePath
      self.agreed_to_license_hash = Digest::SHA256.hexdigest(File.read(Dir.glob(Rails.root.join('lib', 'assets', 'contribution_licenses', 'CP-*.md')).max_by { |f| File.mtime(f) }))
      # rubocop:enable Rails/FilePath
    end

    def set_whitelabel
      self.whitelabel = mission&.whitelabel
    end

    def broadcast_hot_wallet_mode
      broadcast_replace_later_to 'project_hot_wallet_modes',
                                 target: "project_#{id}_hot_wallet_mode",
                                 partial: 'dashboard/transfers/hot_wallet_mode', locals: { project: self }

      broadcast_replace_later_to "transfer_project_#{id}_hot_wallet_mode",
                                 target: "transfer_project_#{id}_hot_wallet_mode",
                                 partial: 'shared/transfer_prioritize_button/mode', locals: { project: self }
    end

    def broadcast_batch_size
      broadcast_replace_later_to 'project_transfer_batch_size',
                                 target: "project_#{id}_transfer_batch_size",
                                 partial: 'dashboard/transfers/batch_size', locals: { project: self }

      broadcast_replace_later_to 'project_transfer_batch_size_modal_form',
                                 target: "project_#{id}_transfer_batch_size_modal_form",
                                 partial: 'projects/batch_size_modal_form', locals: { project: self }
    end
end
