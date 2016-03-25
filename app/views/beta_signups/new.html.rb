class Views::BetaSignups::New < Views::Base
  needs :beta_signup

  OPT_IN_SUBMIT_BUTTON_TEXT = "Great, let me know!"
  OPT_OUT_SUBMIT_BUTTON_TEXT = "I'll check back later"

  def content
    h1 "Sign Up For Free Beta Access"

    p "We will let you know when you can login to CoMakery from your slack instance"

    form_for beta_signup do |f|
      row {
        column("small-6") {
          f.label(:email_address, "Email")
          f.text_field(:email_address, type: "email")
        }
        column("small-6") {}
      }
      f.submit(value: OPT_IN_SUBMIT_BUTTON_TEXT, class: "opt-in")
      f.submit(value: OPT_OUT_SUBMIT_BUTTON_TEXT, class: "opt-out")
    end
  end
end
