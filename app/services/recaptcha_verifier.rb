class RecaptchaVerifier
  def initialize(model:, action:)
    @model = model
    @action = action
  end

  def valid?
    return true unless enabled?

    verify_recaptcha(model: model, action: action)
  end

  private

  attr_reader :model, :action

  def enabled?
    ENV['RECAPTCHA_SITE_KEY'].present? && ENV['RECAPTCHA_SECRET_KEY'].present?
  end
end
