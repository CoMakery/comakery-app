class OreIdService
  class OreIdService::Error < StandardError; end
  class OreIdService::RemoteUserExistsError < StandardError; end
  class OreIdService::RemoteInvalidError < StandardError; end

  include HTTParty
  base_uri 'https://service.oreid.io/api'

  attr_reader :ore_id, :account

  def initialize(ore_id)
    @ore_id = ore_id
    @account = ore_id.account
  end

  def create_remote
    response = handle_response(
      self.class.post(
        '/custodial/new-user',
        headers: request_headers,
        body: create_remote_params.to_json
      )
    )

    ore_id.update(account_name: response['accountName'], state: :unclaimed)
    response
  end

  def remote
    raise OreIdService::RemoteInvalidError unless ore_id.account_name

    @remote ||= handle_response(
      self.class.get(
        "/account/user?account=#{ore_id.account_name}",
        headers: request_headers
      )
    )
  end

  def permissions
    @permissions ||= filtered_permissions.map do |params|
      {
        _blockchain: Blockchain.find_with_ore_id_name(params['chainNetwork']).name.underscore,
        address: params['chainAccount']
      }
    end
  rescue NoMethodError
    raise OreIdService::RemoteInvalidError
  end

  def create_token
    response = handle_response(
      self.class.post(
        '/app-token',
        headers: request_headers
      )
    )

    response['appAccessToken']
  end

  def authorization_url(callback_url, state = nil)
    params = {
      app_access_token: create_token,
      provider: :email,
      callback_url: callback_url,
      background_color: 'FFFFFF',
      state: state
    }

    "https://service.oreid.io/auth?#{params.to_query}"
  end

  def sign_url(transfer:, callback_url:, state:)
    issuer = transfer.issuer
    recipient = transfer.account
    issuer_ore_id = issuer.ore_id_account
    blockchain = transfer.token.blockchain
    issuer_wallet = issuer.wallets.find_by!(_blockchain: blockchain.key)
    recipient_wallet = recipient.wallets.find_by!(_blockchain: blockchain.key)
    transaction_data = {
      from: issuer_wallet.address,
      to: recipient_wallet.address,
      amount: (transfer.amount * 1000000).to_i, # in microalgos
      note: 'Payment from CoMakary', # add transfer_id here
      type: 'pay'
    }

    params = {
      app_access_token: create_token,
      account: issuer_ore_id.account_name,
      chain_account: issuer_wallet.address,
      broadcast: true,
      chain_network: blockchain.ore_id_name,
      return_signed_transaction: true,
      transaction: Base64.encode64(transaction_data.to_json),
      callback_url: callback_url,
      state: state
    }

    "https://service.oreid.io/sign?#{params.to_query}"
  end

  private

    def create_remote_params
      {
        'name' => account.name,
        'user_name' => account.nickname || '',
        'email' => account.email,
        'picture' => account.image ? Refile.attachment_url(account, :image) : '',
        'user_password' => SecureRandom.hex(32) + '!',
        'phone' => '',
        'account_type' => 'native'
      }
    end

    def request_headers
      {
        'api-key' => ENV['ORE_ID_API_KEY'],
        'service-key' => ENV['ORE_ID_SERVICE_KEY'],
        'Content-Type' => 'application/json'
      }
    end

    def filtered_permissions
      remote['permissions'].select { |p| p['permission'] == 'active' }.uniq { |p| p['chainNetwork'] }
    end

    def handle_response(resp)
      body = JSON.parse(resp.body)

      case resp.code
      when 200
        body
      else
        raise_error(body)
      end
    end

    def raise_error(body)
      case body['errorCode']
      when 'userAlreadyExists'
        raise OreIdService::RemoteUserExistsError
      else
        raise OreIdService::Error, "#{body['message']} (#{body['errorCode']} #{body['error']})"
      end
    end
end
