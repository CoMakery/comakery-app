class Api::V1::WalletRecoveryController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::RequiresAnAuthorization
  include Api::V1::Concerns::RequiresSignature
  include Api::V1::Concerns::RequiresWhitelabelMission

  # GET /api/v1/wallet_recovery/public_wrapping_key
  def public_wrapping_key
    render 'public_wrapping_key.json', locals: { wrapping_key_public: wrapping_key_public }
  rescue OpenSSL::BNError, OpenSSL::PKey::ECError
    @errors = { wrapping_key_private: 'is invalid' }
    render 'api/v1/error.json', status: :internal_server_error
  end

  # POST /api/v1/wallet_recovery/recover
  def recover
    recovery = ApiRequestLog.find_by(signature: recovery_token)&.create_api_ore_id_wallet_recovery

    if recovery&.persisted?
      begin
        # TODO: run `ore_id_account.schedule_password_update_sync` here instead of `WalletController#password_reset_url`

        @data = re_encrypted_payload
        render 'api/v1/data.json', status: :created
      rescue OpenSSL::BNError, OpenSSL::PKey::ECError, OpenSSL::PKey::EC::Point::Error
        @errors = { payload: 'cannot be processed' }
        render 'api/v1/error.json', status: :bad_request
      end
    else
      @errors = { recovery_token: 'is invalid' }
      render 'api/v1/error.json', status: :unauthorized
    end
  end

  private

    def wrapping_key_private
      @wrapping_key_private ||= ECIES::Crypt.private_key_from_hex(ENV.fetch('WALLET_RECOVERY_WRAPPING_KEY', 'default_key'))
    end

    def wrapping_key_public
      @wrapping_key_public ||= ECIES::Crypt.calculate_public_key(wrapping_key_private)
    end

    def transport_public_key
      @transport_public_key ||= ECIES::Crypt.public_key_from_hex(params.dig(:body, :data, :transport_public_key))
    end

    def recovery_token
      @recovery_token ||= params.dig(:body, :data, :recovery_token)
    end

    def payload
      @payload ||= params.dig(:body, :data, :payload)
    end

    def decrypted_payload
      @decrypted_payload ||= ECIES::Crypt.new.decrypt(wrapping_key_private, [payload].pack('H*'))
    end

    def re_encrypted_payload
      @re_encrypted_payload ||= ECIES::Crypt.new.encrypt(transport_public_key, decrypted_payload).unpack1('H*')
    end
end
