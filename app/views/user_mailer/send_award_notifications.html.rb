class Views::UserMailer::SendAwardNotifications < Views::Base
  needs :url, :owner, :award
  def content
    row {
      p {
        text "Good news! #{owner} sent you a 10 token \"#{award.award_type.name}\" award for the project named #{award.project.title}."
      }
      p {
        span(style: 'font-weight: bold') {
          text 'Now all you have to do is click '
          link_to 'here', url
          text ' to receive your award.'
        }
      }
      p {
        text 'We always knew you had it in you. Look at those tokens adding up!'
      }
      p {
        text 'If you ever have any questions, concerns, or compliments, please email us directly at community@comakery.com'
      }
      p {
        text 'Congrats from the team at CoMakery. Thank you for being a part of the community!'
      }
    }
  end
end
