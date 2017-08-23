class Views::BetaSignups::New < Views::Base
  needs :beta_signup

  OPT_IN_SUBMIT_BUTTON_TEXT = 'Great, let me know!'.freeze
  OPT_OUT_SUBMIT_BUTTON_TEXT = "I'll check back later".freeze

  def content
    h1 'Sign Up For Free Beta Access'

    p 'We will let you know when you can login to CoMakery from your slack instance'

    form_for beta_signup do |f|
      row do
        column('small-6') do
          f.hidden_field(:email_address)

          p(class: 'beta_signup_email_address') do
            text 'Email: '
            i f.object.email_address
          end
        end
        column('small-6') {}
      end
      f.submit(value: OPT_IN_SUBMIT_BUTTON_TEXT, class: buttonish << 'opt-in' << 'primary' << 'margin-right-small')
      f.submit(value: OPT_OUT_SUBMIT_BUTTON_TEXT, class: buttonish << 'opt-out' << 'secondary')
    end
  end
end
