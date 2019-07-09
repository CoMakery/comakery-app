class Project < ApplicationRecord
  nilify_blanks
  attachment :image

  attachment :square_image, type: :image
  attachment :panoramic_image, type: :image

  belongs_to :account
  belongs_to :mission, optional: true
  belongs_to :token, optional: true
  has_many :interests

  has_many :award_types, inverse_of: :project, dependent: :destroy
  has_many :awards, through: :award_types, dependent: :destroy
  has_many :completed_awards, -> { where.not ethereum_transaction_address: nil }, through: :award_types, source: :awards
  has_many :channels, -> { order :created_at }, inverse_of: :project, dependent: :destroy

  has_many :contributors, through: :awards, source: :account # TODO: deprecate in favor of contributors_distinct
  has_many :contributors_distinct, -> { distinct }, through: :awards, source: :account
  has_many :teams, through: :account

  accepts_nested_attributes_for :channels, reject_if: :invalid_channel, allow_destroy: true

  enum payment_type: {
    project_token: 1
  }
  enum visibility: %i[member public_listed member_unlisted public_unlisted archived]
  enum status: %i[active passive]

  validates :description, :account, :title, :legal_project_owner, presence: true
  validates :long_id, presence: { message: "identifier can't be blank" }
  validates :long_id, uniqueness: { message: "identifier can't be blank or not unique" }
  validates :maximum_tokens, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validate :valid_tracker_url, if: -> { tracker.present? }
  validate :valid_contributor_agreement_url, if: -> { contributor_agreement_url.present? }
  validate :valid_video_url, if: -> { video_url.present? }
  validate :token_changeable, if: -> { token_id_changed? && token_id_was.present? }

  after_save :udpate_awards_if_token_was_added, if: -> { saved_change_to_token_id? && token_id_before_last_save.nil? }

  scope :featured, -> { order :featured }
  scope :unlisted, -> { where 'projects.visibility in(2,3)' }
  scope :listed, -> { where 'projects.visibility not in(2,3)' }
  scope :visible, -> { where 'projects.visibility not in(2,3,4)' }
  scope :unarchived, -> { where.not visibility: 4 }
  scope :publics, -> { where 'projects.visibility in(1)' }

  delegate :coin_type, to: :token, allow_nil: true
  delegate :coin_type_on_ethereum?, to: :token, allow_nil: true
  delegate :coin_type_on_qtum?, to: :token, allow_nil: true
  delegate :transitioned_to_ethereum_enabled?, to: :token, allow_nil: true
  delegate :decimal_places_value, to: :token, allow_nil: true
  delegate :populate_token?, to: :token, allow_nil: true
  delegate :total_awarded, to: :awards, allow_nil: true

  def self.with_last_activity_at
    select(Project.column_names.map { |c| "projects.#{c}" }.<<('max(awards.created_at) as last_award_created_at').join(','))
      .joins('left join award_types on projects.id = award_types.project_id')
      .joins('left join awards on award_types.id = awards.award_type_id')
      .group('projects.id')
      .order('max(awards.created_at) desc nulls last, projects.created_at desc nulls last')
  end

  def top_contributors
    Account.select('accounts.*, sum(a1.total_amount) as total_awarded, max(a1.created_at) as last_awarded_at').joins("
      left join awards a1 on a1.account_id=accounts.id and a1.status in(3,5)
      left join award_types on a1.award_type_id=award_types.id
      left join projects on award_types.project_id=projects.id")
           .where('projects.id=?', id)
           .group('accounts.id')
           .order('total_awarded desc, last_awarded_at desc').first(5)
  end

  def total_month_awarded
    awards.completed.where('awards.created_at >= ?', Time.zone.today.beginning_of_month).sum(:total_amount)
  end

  def total_awards_outstanding
    total_awarded - total_awards_redeemed
  end

  def community_award_types
    award_types.where(community_awardable: true)
  end

  def invalid_channel(attributes)
    Channel.invalid_params(attributes)
  end

  # def owner_slack_user_name
  #   account.authentications.find_by(slack_team_id: slack_team_id)&.display_name
  # end

  def video_id
    # taken from http://stackoverflow.com/questions/5909121/converting-a-regular-youtube-link-into-an-embedded-video
    # Regex from http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
    # Vimeo regex from https://stackoverflow.com/questions/41208456/javascript-regex-vimeo-id

    case video_url
    when /youtu\.be\/([^\?]*)/
      Regexp.last_match(1)
    when /^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/
      Regexp.last_match(5)
    when /(?:www\.|player\.)?vimeo.com\/(?:channels\/(?:\w+\/)?|groups\/(?:[^\/]*)\/videos\/|album\/(?:\d+)\/video\/|video\/|)(\d+)([a-zA-Z0-9_\-]*)?/i
      Regexp.last_match(1)
    end
  end

  def show_id
    unlisted? ? long_id : id
  end

  def public?
    public_listed? || public_unlisted?
  end

  def unarchived?
    Project.unarchived.where(id: id).present?
  end

  def unlisted?
    member_unlisted? || public_unlisted?
  end

  def percent_awarded
    if maximum_tokens
      total_awarded * 100.0 / maximum_tokens
    else
      0
    end
  end

  def awards_for_chart(max: 1000)
    result = []
    recents = awards.completed.limit(max).order('id desc')
    date_groups = recents.group_by { |a| a.created_at.strftime('%Y-%m-%d') }
    if awards.completed.count > max
      date_groups.delete(recents.first.created_at.strftime('%Y-%m-%d'))
    end
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
    awards.ready.group_by(&:specialty).map { |specialty, awards| [specialty, awards.take(limit_per_specialty)] }.to_h
  end

  def stats
    {
      batches: award_types.where(published: true).size,
      tasks: awards.in_progress.size,
      interests: (
        [account_id] |
        interests.pluck(:account_id) |
        awards.pluck(:account_id)
      ).size
    }
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

  def udpate_awards_if_token_was_added
    awards.paid.each { |a| a.update(status: :accepted) }
  end
end
