class Channel < ApplicationRecord
  belongs_to :project
  belongs_to :team

  delegate :provider, to: :project
  validates :name, :team_id, :project, presence: true

  attr_accessor :channels
  def provider
    self.team.provider if self.team
  end

  def get_channels
    @channels ||= auth_team.channels if auth_team
    @channels
  end

  def teams
    return project.teams.where(provider: self.provider) if self.project
    []
  end

  def auth_team
    if self.project && self.team
      @auth_team ||= self.team.authentication_teams.find_by account_id: self.project.account_id
    end
    @auth_team
  end

  def self.invalid_params(attributes)
    attributes['name'].blank? || attributes['team_id'].blank?
  end
end
