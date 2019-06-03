module SignatureHelper
  def signature(payload)
    CGI.escape(ActiveSupport::MessageVerifier.new(Rails.application.secrets.secret_key_base).generate(payload))
  end

  def signature_valid?(payload, provided_signature)
    signature(payload) == provided_signature
  end
end
