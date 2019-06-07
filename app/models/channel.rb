class Channel < ApplicationRecord
  belongs_to :project, touch: true
  belongs_to :team

  validates :channel_id, :team, :project, presence: true

  attr_accessor :channels
  delegate :provider, to: :team, allow_nil: true

  DISCORD_INVITE_MAX_AGE_SECONDS = 3600

  def name_with_provider
    return name unless team
    "[#{provider}] #{team.name} ##{name}"
  end

  def fetch_channels
    @channels ||= auth_team.channels if auth_team
    @channels
  end

  def teams
    return project.account.manager_teams.where(provider: provider) if project
  end

  def members
    return @members if @members
    @members = team.discord? ? team.members_for_select : slack_members
  end

  def slack_members
    return @members if @members
    slack = auth_team.slack
    @members = slack.get_users[:members].map { |user| [api_formatted_name(user), user[:id]] }
    @members = @members.sort_by { |member| member.first.downcase.sub(/\A@/, '') }
    @members
  end

  delegate :authentication, to: :auth_team

  def auth_team
    if project && team
      @auth_team ||= team.authentication_teams.find_by account_id: project.account_id
    end
    @auth_team
  end

  def self.invalid_params(attributes)
    attributes['channel_id'].blank? || attributes['team_id'].blank?
  end

  def url
    case provider
    when 'slack'
      "https://#{team.domain}.slack.com/messages/#{channel_id}"
    when 'discord'
      "https://discord.gg/#{discord_invite}"
    end
  end

  def discord_invite
    if discord_invite_created_at.nil? || (Time.zone.now - discord_invite_created_at >= DISCORD_INVITE_MAX_AGE_SECONDS)
      update(
        discord_invite_code: Comakery::Discord.new.create_invite(channel_id)&.fetch('code'),
        discord_invite_created_at: Time.zone.now
      )
    end

    discord_invite_code
  end

  before_save :assign_name

  private

  def assign_name
    self.name = team.discord? ? team.decorate.channel_name(channel_id) : channel_id
  end

  def api_formatted_name(user)
    real_name = [user[:profile][:first_name].presence, user[:profile][:last_name].presence].compact.join(' ')
    [real_name.presence, "@#{user[:name]}"].compact.join(' - ')
  end
end
