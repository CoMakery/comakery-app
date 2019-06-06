class AwardMessage
  include Interactor
  include ::Rails.application.routes.url_helpers

  def call
    award = context.award.decorate
    context.notifications_message = notifications_message(award)
  end

  def notifications_message(award)
    %(
      #{award.issuer_user_name} accepted #{award.recepient_user_name} task #{award.name} on the #{award.project.title} project: #{project_url(award.project)}.
      Login to CoMakery with your #{award.discord? ? 'Discord' : 'Slack'} account to claim project awards and start new tasks: #{new_session_url}.
    ).strip
  end
end
