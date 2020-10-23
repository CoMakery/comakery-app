class OreIdService
  class OreIdService::Error < StandardError; end

  include HTTParty
  base_uri 'https://service.oreid.io/api'

  attr_reader :ore_id, :account

  def initialize(ore_id)
    @ore_id = ore_id
    @account = ore_id.account
  end

  def remote
    @remote ||= (pull_remote || create_remote)
  end

  def account_name
    @account_name ||= remote['accountName']
  end

  def permissions
    @permissions ||= remote['permissions'].select { |p| p['permission'] == 'active' }.uniq { |p| p['chainNetwork'] }.map do |params|
      {
        _blockchain: Blockchain.find_with_ore_id_name(params['chainNetwork']).name.underscore,
        address: params['chainAccount']
      }
    end
  end

  private

    def pull_remote
      return unless ore_id.account_name

      handle_response(
        self.class.get(
          "/account/user?account=#{ore_id.account_name}",
          headers: request_headers
        )
      )
    end

    def create_remote
      handle_response(
        self.class.post(
          '/custodial/new-user',
          headers: request_headers,
          body: create_remote_params.to_json
        )
      )
    end

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

    def handle_response(resp)
      body = JSON.parse(resp.body)

      case resp.code
      when 200
        body
      when 404, 400
        nil
      else
        raise OreIdService::Error, "#{body['message']} (#{body['errorCode']} #{body['error']})"
      end
    end
end
