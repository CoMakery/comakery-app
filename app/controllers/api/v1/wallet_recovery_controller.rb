class Api::V1::WalletRecoveryController < Api::V1::ApiController
  include Api::V1::Concerns::AuthorizableByMissionKey
  include Api::V1::Concerns::RequiresAnAuthorization
  include Api::V1::Concerns::RequiresSignature
  include Api::V1::Concerns::RequiresWhitelabelMission

  def public_wrapping_key
    private_key = ENV.fetch('WALLET_RECOVERY_WRAPPING_KEY', 'default_key')
    public_key = Eth::Key.new(priv: private_key).public_key.key
    render json: { public_wrapping_key: public_key }
  rescue MoneyTree::Key::KeyFormatNotFound
    @errors = { invalid_env_variable: 'WALLET_RECOVERY_WRAPPING_KEY variable was not configured or use wrong format' }
    render 'api/v1/error.json', status: :internal_server_error
  end
end
