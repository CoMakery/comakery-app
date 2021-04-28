module ProtectedWithRecaptcha
  extend ActiveSupport::Concern

  def recaptcha_valid?(model:, action:)
    @model = model
    @action = action

    result = verify_recaptcha_v3 || verify_recaptcha_v2
    @fallback_to_recaptcha_v2 = true unless result

    result
  end

  def verify_recaptcha_v3
    verify_recaptcha(model: @model, minimum_score: 0.5, action: @action)
  end

  def verify_recaptcha_v2
    verify_recaptcha(model: @model, secret_key: ENV['RECAPTCHA_SECRET_KEY_V2'])
  end
end
