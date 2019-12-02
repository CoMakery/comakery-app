class Views::UserMailer::ConfirmEmail < Views::Base
  use_instance_variables_for_assigns true
  needs :url, :brand_name

  def content
    row do
      p do
        text 'Click this '
        link_to 'link', url
        text " to verify your email address with #{@brand_name}, and we’ll take care of the rest."
      end
      p do
        text "From the team at #{@brand_name}, thank you for joining our community. We’re delighted to have you!"
      end
    end
  end
end
