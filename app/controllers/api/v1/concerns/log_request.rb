module Api::V1::Concerns::LogRequest
  extend ActiveSupport::Concern

  included do
    def log_request(request_body, ip)
      ApiRequestLog.create!(
        ip: ip,
        body: request_body,
        signature: request_body.dig('proof', 'signature')
      )
    end
  end
end
