class Views::BetaSignups::New < Views::Base
  needs :beta_signup

  OPT_IN_SUBMIT_BUTTON_TEXT = 'Great, let me know!'.freeze
  OPT_OUT_SUBMIT_BUTTON_TEXT = "I'll check back later".freeze

  def content
    h1 'Sign Up For Free Beta Access'

    p "We will let you know when you can login to #{Rails.application.config.project_name} from your slack instance"

    form_for beta_signup do |f|
      row {
        column('small-6') {
          f.hidden_field(:email_address)

          p(class: 'beta_signup_email_address') {
            text 'Email: '
            i f.object.email_address
          }
        }
        column('small-6') {}
      }
      f.submit(value: OPT_IN_SUBMIT_BUTTON_TEXT, class: buttonish << 'opt-in' << 'primary' << 'margin-right-small')
      f.submit(value: OPT_OUT_SUBMIT_BUTTON_TEXT, class: buttonish << 'opt-out' << 'secondary')
    end
  end
end
