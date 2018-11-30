class Account < ApplicationRecord
  paginates_per 50
  has_secure_password validations: false
  attachment :image
  include EthereumAddressable
  include QtumAddressable

  has_many :authentications, -> { order(updated_at: :desc) }, dependent: :destroy
  has_many :authentication_teams, dependent: :destroy
  has_many :teams, through: :authentication_teams
  has_many :manager_auth_teams, -> { where("manager=true or provider='slack'") }, class_name: 'AuthenticationTeam'
  has_many :manager_teams, through: :manager_auth_teams, source: :team
  has_many :team_projects, through: :teams, source: :projects
  has_many :team_awards, through: :team_projects, source: :awards
  has_many :awards, dependent: :destroy
  has_many :award_projects, through: :awards, source: :project
  has_one :slack_auth, -> { where(provider: 'slack').order('updated_at desc').limit(1) }, class_name: 'Authentication'
  # default_scope { includes(:slack_auth) }
  has_many :projects
  has_many :payments
  has_many :channels, through: :projects
  has_many :interests, dependent: :destroy
  validates :email, presence: true, uniqueness: true
  attr_accessor :password_required, :name_required, :agreement_required
  validates :password, length: { minimum: 8 }, if: :password_required
  validates :first_name, :last_name, :country, :date_of_birth, presence: true, if: :name_required

  validates :public_address, uniqueness: { case_sensitive: false }, allow_nil: true
  validates :ethereum_wallet, ethereum_address: { type: :account } # see EthereumAddressable
  validates :qtum_wallet, qtum_address: true # see QtumAddressable
  validates :email, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ }, allow_nil: true
  validate :validate_age, on: :create
  validates :agreed_to_user_agreement, presence: { message: 'You must agree to the terms of the CoMakery User Agreement to sign up ' }, if: :agreement_required

  class << self
    def order_by_award(project)
      award_types = project.award_types.map(&:id).join(',')
      return Account.none if award_types.blank?
      select("accounts.*, (select sum(total_amount) from awards where awards.account_id = accounts.id and awards.award_type_id in(#{award_types})) as total").distinct.order('total desc')
    end

    def find_from_uid_channel(uid, channel)
      authentication = Authentication.find_by(uid: uid)
      if authentication
        account = authentication.account
      elsif channel
        account = find_by(email: fetch_email(uid, channel))
      end
      account
    end

    def find_or_create_for_authentication(uid, channel)
      authentication = Authentication.find_by(uid: uid)
      if authentication
        account = authentication.account
      elsif channel
        account = find_or_create_by(email: fetch_email(uid, channel))
        account.nickname = fetch_nickname(uid, channel)
        errors = if account.save
          account.create_authentication_and_build_team(uid, channel)
        end
      end
      [account, errors]
    end

    def fetch_email(uid, channel)
      email = "#{uid}@discordapp.com"
      email = slack_info(uid, channel).user.profile.email || "#{uid}@slackbot.com" if channel.team.slack?
      email
    end

    def fetch_nickname(uid, channel)
      channel.team.discord? ? discord_info(uid)['username'] : slack_info(uid, channel).user.name
    end

    def slack_info(uid, channel)
      @slack_info = Comakery::Slack.new(channel.authentication.token).get_user_info(uid) if uid != @slack_info&.user&.id
      @slack_info
    end

    def discord_info(uid)
      @discord_info = Comakery::Discord.new.user_info(uid)
    end
  end
  before_save :downcase_email

  def create_authentication_and_build_team(uid, channel)
    auth = authentications.create(provider: channel.team.provider, uid: uid)
    channel.team.build_authentication_team auth if auth.valid?
    auth.errors.full_messages.join(', ')
  end

  def downcase_email
    self.email = email.try(:downcase)
  end

  def slack
    @slack ||= Comakery::Slack.get(slack_auth.token)
  end

  def confirm!
    update email_confirm_token: nil
  end

  def award_by_project(project)
    groups = project.awards.where(account: self).group_by { |a| a.award_type.name }
    arr = []
    groups.each do |group|
      arr << { name: group[0], total: group[1].sum(&:total_amount) }
    end
    arr.sort { |i, j| j[:total] <=> i[:total] }
  end

  def total_awards_earned(project)
    project.awards.where(account: self).sum(:total_amount)
  end

  def total_awards_paid(project)
    project.payments.where(account: self).sum(:quantity_redeemed)
  end

  def total_awards_remaining(project)
    total_awards_earned(project) - total_awards_paid(project)
  end

  def total_revenue_paid(project)
    project.payments.where(account: self).sum(:total_value)
  end

  def total_revenue_unpaid(project)
    project.share_of_revenue_unpaid(total_awards_remaining(project))
  end

  def percent_unpaid(project)
    return BigDecimal('0') if project.total_awards_outstanding.zero?
    precise_percentage = (BigDecimal(total_awards_remaining(project)) * 100) / BigDecimal(project.total_awards_outstanding)
    precise_percentage.truncate(8)
  end

  def other_member_projects
    Project.joins("
      left join award_types at1 on at1.project_id=projects.id
      left join awards a1 on a1.award_type_id=at1.id
      left join channels on channels.project_id=projects.id
      left join teams on teams.id=channels.team_id
      left join authentication_teams on authentication_teams.team_id=teams.id")
           .where("((authentication_teams.account_id=#{id} and channels.id is not null) or a1.account_id=#{id}) and projects.account_id <> #{id}").distinct
  end

  def accessable_projects
    Project.joins("
      left join award_types on award_types.project_id=projects.id
      left join (select account_id,
                        award_type_id
                 from awards
                 where account_id = #{id}) as awards
                                       on awards.award_type_id=award_types.id
      left join channels on channels.project_id=projects.id
      left join teams on teams.id=channels.team_id
      left join authentication_teams on authentication_teams.team_id=teams.id")
           .where("(authentication_teams.account_id=#{id} and channels.id is not null) or projects.visibility=1 or awards.account_id=#{id} or projects.account_id=#{id}").distinct
  end

  def confirmed?
    email_confirm_token.nil?
  end

  def interested?(protocol, project)
    interests.find_by protocol: protocol, project: project
  end

  def finished_contributor_form?
    contributor_form == true
  end

  def valid_and_underage?
    self.name_required = true
    valid? && age < 18
  end

  def owned_project?(project)
    project.account_id == id
  end

  def same_team_project?(project)
    team_projects.include?(project)
  end

  def same_team_or_owned_project?(project)
    owned_project?(project) || same_team_project?(project) || award_projects.include?(project)
  end

  def send_reset_password_request
    update reset_password_token: SecureRandom.hex
    UserMailer.reset_password(self).deliver_now
  end

  def age
    return nil unless date_of_birth
    calculate_age
  end

  def to_csv
    Comakery::CSV.generate_multiplatform do |csv|
      csv << ['First Name', 'Last Name', 'Email', 'Nickname', 'Date of Birth', 'Age', 'Country']
      csv << [first_name, last_name, email, nickname, date_of_birth, age, country]
    end
  end

  def awards_csv
    Comakery::CSV.generate_multiplatform do |csv|
      csv << ['Project', 'Award Type', 'Total Amount', 'Issuer', 'Date']
      awards.order(:created_at).decorate.each do |award|
        csv << [award.project.title, award.award_type.name, award.total_amount_pretty, award.issuer_display_name, award.created_at.strftime('%b %d, %Y')]
      end
    end
  end

  after_update :check_email_update

  private

  def validate_age
    errors.add(:date_of_birth, 'You must be at least 18 years old to use CoMakery.') if age && age < 18
  end

  def calculate_age
    now = Time.zone.now.to_date
    result = now.year - date_of_birth.year
    result -= 1 if now.month < date_of_birth.month || now.month == date_of_birth.month && now.day < date_of_birth.day
    result
  end

  def check_email_update
    if saved_change_to_email?
      # rubocop:disable SkipsModelValidations
      update_column :email_confirm_token, SecureRandom.hex
      UserMailer.confirm_email(self).deliver
    end
  end
end
