require 'ed25519'
require 'securerandom'
require 'base64'

# Implements signing and verifying Comkakery API requests with Ed25519 digital signature algorithm
#
#
# Format of the request (JSON):
# ```
# {
#   "body": {
#     "data": {},
#     "url": "https://example.org/",
#     "method": "GET",
#     "nonce": "ajgpe79rv6sv1i8sqhxobd",
#     "timestamp": 1579539467614
#   },
#   "proof": {
#     "type": "Ed25519Signature2018",
#     "verificationMethod": "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
#     "signature": "FeDeSZNqfvz/EmfhIxz+tvRFXn83Xm0SUpcI/AJQDre0tGInJ96+/HN0nhG2vHPevKfpGaq9cr0zwuC6OEbvCQ=="
#   }
# }
# ```
#
#
# Example – Signing request:
# ```
# private_key = 'eodjQfDLTyNCBnz+MORHW0lOKWZnCTyPDTFcwAdVRyQ7vNMfjEecPWNEqF4FOuk03bgWDV10vwMcqL/OBUJWkA=='
#
# request = {
#   "body" => {
#     "data" => {}
#   }
# }
#
# signed_request = Comakery::APISignature.new(request).sign(private_key)
# ```
#
#
# Example – Verifying request:
# ```
# public_key = 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA='
#
# request = {
#   "body" => {
#     "data" => {},
#     "url" => "https://example.org/",
#     "method" => "GET",
#     "nonce" =>"ajgpe79rv6sv1i8sqhxobd",
#     "timestamp" => 1579539467614
#   },
#   "proof" => {
#     "type" => "Ed25519Signature2018",
#     "verificationMethod" => "O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=",
#     "signature" => "FeDeSZNqfvz/EmfhIxz+tvRFXn83Xm0SUpcI/AJQDre0tGInJ96+/HN0nhG2vHPevKfpGaq9cr0zwuC6OEbvCQ=="
#   }
# }
#
# is_nonce_unique = -> (nonce) { ['1', '2', '3'].none? nonce }
# http_url = "https://example.org/"
# http_method = "GET"
#
# begin
#   Comakery::APISignature.new(request, http_url, http_method, is_nonce_unique).verify(public_key)
# rescue Comakery::APISignatureError => e
#   e.message
# end
# ```
#
#
# Example – Usage in CLI:
# `$ irb -r api_signature.rb -e 'puts Comakery::APISignature.new(File.read("request.json")).sign(File.read("key"))'`
# `$ irb -r api_signature.rb -e 'puts Comakery::APISignature.new(File.read("request.json")).verify(File.read("key.pub"))'`

module Comakery
  # Raised during unsuccessfull signature verification
  APISignatureError = Class.new(StandardError)

  # Verifying and generating signature
  class APISignature
    # Proof type identifier according Linked Data Cryptographic Suite Registry
    PROOF_TYPE = 'Ed25519Signature2018'.freeze

    # Allowed expiration time for timestamp
    TIMESTAMP_EXPIRATION_SECONDS = 60

    # Allowed ahead of time for timestamp
    TIMESTAMP_AHEAD_SECONDS = 3

    # Creates a new request to be verified
    #
    # @param request [Hash] request including body and optioanl proof
    # @param http_url [String] url of the request (optional)
    # @param http_method [String] HTTP method of the request (optional)
    # @param is_nonce_unique [Proc] lambda function to verify unqiuness of the nonce for the given timewindow (optional)
    def initialize(request, http_url = '', http_method = '', is_nonce_unique = ->(nonce) { true if nonce })
      @request = request
      @http_url = http_url
      @http_method = http_method
      @is_nonce_unique = is_nonce_unique
    end

    # Signs the request with given private key, appending nonce, timestamp and proof
    #
    # @param private_key [String] 64-bit keypair strict-encoded in base64
    #
    # @return [Hash] signed request
    def sign(private_key)
      signing_key = Ed25519::SigningKey.from_keypair(Base64.decode64(private_key))

      @request['body']['nonce'] = nonce
      @request['body']['timestamp'] = timestamp.to_s
      @request['proof'] = {}
      @request['proof']['type'] = PROOF_TYPE
      @request['proof']['verificationMethod'] = Base64.strict_encode64(
        signing_key.verify_key.to_bytes
      )
      @request['proof']['signature'] = Base64.strict_encode64(
        signing_key.sign(@request['body'].to_json_c14n)
      )

      @request
    end

    # Verifies that:
    # – signature of request by serializing body (data, http_url, http_method, nonce and timestamp)
    # - timestamp fits into defined window (between TIMESTAMP_EXPIRATION_SECONDS and TIMESTAMP_AHEAD_SECONDS)
    # - nonce is unique for provided nonce_history (see #new)
    # - http_url matches provided one (see #new)
    # - http_method matches provided one (see #new)
    #
    # @param public_key [String] 32-bit key strict-encoded in base64
    #
    # @return [Boolean] result of verification
    def verify(public_key)
      verify_http_url
      verify_http_method
      verify_type
      verify_timestamp
      verify_nonce
      verify_method(public_key)
      verify_signature(public_key)

      true
    end

    private

      def nonce
        SecureRandom.hex
      end

      def timestamp
        Time.now.utc.to_i
      end

      def verify_http_url
        raise Comakery::APISignatureError, 'Invalid URL' unless @request.fetch('body', {}).fetch('url', '') == @http_url
      end

      def verify_http_method
        raise Comakery::APISignatureError, 'Invalid HTTP method' unless @request.fetch('body', {}).fetch('method', '') == @http_method
      end

      def verify_nonce
        raise Comakery::APISignatureError, 'Invalid nonce' unless @is_nonce_unique.call(@request.fetch('body', {}).fetch('nonce', ''))
      end

      def verify_timestamp
        raise Comakery::APISignatureError, 'Invalid timestamp' unless @request.fetch('body', {}).fetch('timestamp', 0).to_i.between?(timestamp - TIMESTAMP_EXPIRATION_SECONDS, timestamp + TIMESTAMP_AHEAD_SECONDS)
      end

      def verify_type
        raise Comakery::APISignatureError, 'Invalid proof type' unless @request.fetch('proof', {}).fetch('type', '') == PROOF_TYPE
      end

      def verify_method(public_key)
        raise Comakery::APISignatureError, 'Invalid proof verificationMethod' unless (@request.fetch('proof', {}).fetch('verificationMethod', nil) || @request.fetch('proof', {}).fetch('verification_method', nil)) == public_key
      end

      def verify_signature(public_key)
        Ed25519::VerifyKey.new(
          Base64.strict_decode64(public_key)
        ).verify(
          Base64.strict_decode64(
            @request.fetch('proof', {}).fetch('signature', '')
          ),
          @request.fetch('body', {}).to_json_c14n
        )
      rescue Ed25519::VerifyError, ArgumentError
        raise Comakery::APISignatureError, 'Invalid proof signature'
      end
  end
end
