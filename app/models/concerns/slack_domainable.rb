module SlackDomainable
  extend ActiveSupport::Concern

  included do
    validate :valid_slack_team_domain
  end

  def valid_slack_team_domain
    errors[:slack_team_domain] << "can't be blank" if slack_team_domain == ''

    unless slack_team_domain.nil? || slack_team_domain =~ /\A[a-z0-9][a-z0-9-]*\z/
      errors[:slack_team_domain] << 'must only contain lower-case letters, numbers, and hyphens and start with a letter or number'
    end
  end
end
