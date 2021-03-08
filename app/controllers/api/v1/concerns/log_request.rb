module Api::V1::Concerns::LogRequest
  extend ActiveSupport::Concern

  included do
    FILTERED_DATA_KEYS = [:payload].freeze

    def log_request(request_body, ip)
      ApiRequestLog.create!(
        ip: ip,
        body: filter_request_body(request_body),
        signature: request_body.dig('proof', 'signature')
      )
    end

    def filter_request_body(request_body)
      FILTERED_DATA_KEYS.each do |filtered_key|
        request_body[:body][:data][filtered_key] = 'FILTERED' if request_body.dig(:body, :data, filtered_key)
      rescue TypeError
        next
      end

      request_body
    end
  end
end
