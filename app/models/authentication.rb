class Authentication < ApplicationRecord
  include SlackDomainable

  belongs_to :account
  has_many :projects, foreign_key: :slack_team_id, primary_key: :slack_team_id
  validates :account, :provider, :uid, presence: true

  def slack_icon
    slack_image_32_url || slack_team_image_34_url
  end

  def slack_team_ethereum_enabled?
    allow_ethereum = Rails.application.config.allow_ethereum
    allowed_domains = allow_ethereum.to_s.split(',').compact
    allowed_domains.include?(slack_team_domain)
  end

  def total_awards_earned(project)
    project.awards.where(authentication: self).sum(:total_amount)
  end

  def total_awards_paid(project)
    project.payments.where(payee: self).sum(:quantity_redeemed)
  end

  def total_awards_remaining(project)
    total_awards_earned(project) - total_awards_paid(project)
  end

  def total_revenue_paid(project)
    project.payments.where(payee: self).sum(:total_value)
  end

  def total_revenue_unpaid(project)
    project.share_of_revenue_unpaid(total_awards_remaining(project))
  end

  def percent_unpaid(project)
    return BigDecimal('0') if project.total_awards_outstanding == 0
    precise_percentage = (BigDecimal(total_awards_remaining(project)) * 100) / BigDecimal(project.total_awards_outstanding)
    precise_percentage.truncate(8)
  end

  def self.find_or_create_from_auth_hash!(auth_hash)
    slack_auth_hash = SlackAuthHash.new(auth_hash)

    account = Account.find_or_create_by(email: slack_auth_hash.email_address)

    # find the "slack" authentication *for the given slack user* if exists
    # note that we persist an authentication for every team
    authentication = Authentication.find_or_initialize_by(
      provider: slack_auth_hash.provider,
      slack_user_id: slack_auth_hash.slack_user_id,
      slack_team_id: slack_auth_hash.slack_team_id
    )
    authentication.update!(
      account_id: account.id,
      slack_user_name: slack_auth_hash.slack_user_name,
      slack_first_name: slack_auth_hash.slack_first_name,
      slack_last_name: slack_auth_hash.slack_last_name,
      slack_team_name: slack_auth_hash.slack_team_name,
      slack_image_32_url: slack_auth_hash.slack_image_32_url,
      slack_team_image_34_url: slack_auth_hash.slack_team_image_34_url,
      slack_team_image_132_url: slack_auth_hash.slack_team_image_132_url,
      slack_token: slack_auth_hash.slack_token,
      slack_team_domain: slack_auth_hash.slack_team_domain,
      oauth_response: auth_hash
    )
    authentication.touch # we must change updated_at manually: update! does not change updated_at if attrs have not changed

    # This will go away when we create a Team model <https://github.com/CoMakery/comakery-app/issues/113>
    Project.where(slack_team_id: slack_auth_hash.slack_team_id).update_all(
      slack_team_name: slack_auth_hash.slack_team_name,
      slack_team_image_34_url: slack_auth_hash.slack_team_image_34_url,
      slack_team_image_132_url: slack_auth_hash.slack_team_image_132_url,
      slack_team_domain: slack_auth_hash.slack_team_domain
    )

    account
  end
end
