class AwardMessage
  include Interactor
  include ::Rails.application.routes.url_helpers
  def call
    award = context.award.decorate
    context.notifications_message = notifications_message(award)
  end

  def notifications_message(award)
    text = message_info(award)
    text = "#{text} for \"#{award.description}\"" if award.description.present?

    text = if award.discord?
      "#{text} #{discord_message(award)}"
    else
      "#{text} #{slack_message(award)}"
    end

    text.strip!
    text.gsub!(/\s+/, ' ')
    text
  end

  def discord_message(award)
    text = "on the #{award.project.title} project: #{project_url(award.project)}."

    if award.project.token&.ethereum_enabled && award.recipient_address.blank?
      text = "#{text} Set up your account: #{account_url} to receive Ethereum tokens."
    end
    text
  end

  def slack_message(award)
    text = "on the <#{project_url(award.project)}|#{award.project.title}> project."

    if award.project.token&.ethereum_enabled && award.recipient_address.blank?
      text = "#{text} <#{account_url}|Set up your account> to receive Ethereum tokens."
    end
    text
  end

  def message_info(award)
    if award.self_issued?
      "@#{award.issuer_user_name} self-issued"
    else
      "@#{award.issuer_user_name} sent @#{award.recipient_user_name} a #{award.total_amount} token #{award.award_type.name}"
    end
  end
end
