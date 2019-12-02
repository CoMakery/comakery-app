class Views::UserMailer::IncomingAwardNotifications < Views::Base
  use_instance_variables_for_assigns true

  needs :url, :owner, :award, :contact_email, :brand_name
  def content
    row do
      p do
        text "Good news! #{owner} sent you a #{award.total_amount} token \"#{award.award_type.name}\" award for the project named #{award.project.title}."
      end
      p do
        span(style: 'font-weight: bold') do
          text 'Click '
          link_to 'here', url
          text ' to see your account balance.'
        end
      end
      p do
        text 'We always knew you had it in you. Look at those tokens adding up!'
      end
      p do
        text "If you ever have any questions, concerns, or compliments, please email us directly at #{@contact_email}"
      end
      p do
        text "Congrats from the team at #{@brand_name}. Thank you for being a part of the community!"
      end
    end
  end
end
