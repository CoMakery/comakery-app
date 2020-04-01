require 'refile/file_double'

class Mom
  def account(**attrs)
    defaults = {
      email: "me+#{SecureRandom.hex(20)}@example.com",
      first_name: 'Eva',
      last_name: 'Smith',
      nickname: "hunter-#{SecureRandom.hex(20)}",
      date_of_birth: '1990/01/01',
      country: 'United States of America',
      ethereum_wallet: '0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B',
      specialty: create(:specialty),
      password: valid_password
    }
    Account.new(defaults.merge(attrs))
  end

  def specialty(**attrs)
    defaults = {
      name: "Specialty #{SecureRandom.hex(20)}"
    }
    Specialty.new(defaults.merge(attrs))
  end

  def experience(**attrs)
    defaults = {
      specialty: create(:specialty),
      account: create(:account),
      level: 1
    }
    Experience.new(defaults.merge(attrs))
  end

  def verification(**attrs)
    defaults = {
      account: create(:account),
      provider: create(:account),
      passed: true,
      max_investment_usd: 1000000
    }
    Verification.new(defaults.merge(attrs))
  end

  def reg_group(**attrs)
    token = attrs[:token] || create(:token, coin_type: :comakery)

    defaults = {
      token: token,
      name: "RegGroup #{SecureRandom.hex(20)}",
      blockchain_id: RegGroup.maximum(:id).to_i + 1000
    }
    RegGroup.new(defaults.merge(attrs))
  end

  def transfer_rule(**attrs)
    token = attrs[:token] || create(:token, coin_type: :comakery)

    defaults = {
      token: token,
      sending_group: create(:reg_group, token: token),
      receiving_group: create(:reg_group, token: token),
      lockup_until: 1.day.ago
    }
    TransferRule.new(defaults.merge(attrs))
  end

  def account_token_record(**attrs)
    token = attrs[:token] || create(:token, coin_type: :comakery)

    defaults = {
      account: create(:account),
      token: token,
      reg_group: create(:reg_group, token: token),
      max_balance: 100000,
      balance: 200,
      account_frozen: false,
      lockup_until: 1.day.ago
    }
    AccountTokenRecord.new(defaults.merge(attrs))
  end

  def blockchain_transaction(**attrs)
    token = attrs[:token] || create(
      :token,
      coin_type: :comakery,
      ethereum_network: :ropsten,
      ethereum_contract_address: build(:ethereum_contract_address),
      symbol: 'DUM',
      decimal_places: 0
    )
    attrs.delete(:token)

    award = blockchain_transaction_award(attrs.merge(token: token))
    attrs.delete(:award)

    defaults = {
      award: award,
      amount: 1,
      source: build(:ethereum_address_1),
      nonce: token.coin_type_token? ? rand(1_000_000) : nil,
      status: :created,
      status_message: 'dummy'
    }

    VCR.use_cassette("infura/#{token.ethereum_network}/#{token.ethereum_contract_address}/contract_init") do
      BlockchainTransaction.create!(defaults.merge(attrs))
    end
  end

  def blockchain_transaction_award(**attrs)
    attrs[:award] || create(
      :award,
      amount: attrs[:amount] || 1,
      status: :accepted,
      account: create(
        :account,
        ethereum_wallet: attrs[:destination] || build(:ethereum_address_2)
      ),
      award_type: create(
        :award_type,
        project: create(
          :project,
          token: attrs[:token]
        )
      )
    )
  end

  def blockchain_transaction_update(**attrs)
    defaults = {
      blockchain_transaction: create(:blockchain_transaction),
      status: :created,
      status_message: 'dummy'
    }

    BlockchainTransactionUpdate.new(defaults.merge(attrs))
  end

  def account_with_auth(**attrs)
    account(**attrs).tap { |a| create(:authentication, account: a) }
  end

  def cc_authentication(**attrs)
    defaults = {}
    defaults[:account] = account unless attrs.key?(:account)
    authentication(defaults.merge(attrs))
  end

  def sb_authentication(**attrs)
    defaults = {}
    defaults[:account] = account unless attrs.key?(:account)
    authentication(defaults.merge(attrs))
  end

  def authentication(**attrs)
    @@authentication_count ||= 0
    @@authentication_count += 1
    defaults = {
      provider: 'slack',
      token: 'slack token',
      uid: "slack user id #{@@authentication_count}"
    }
    defaults[:account] = create(:account, first_name: 'John', last_name: 'Doe') unless attrs.key?(:account)
    Authentication.new(defaults.merge(attrs))
  end

  def cc_project(account = create(:cc_authentication).account, **attrs)
    project(account, { title: 'Citizen Code', token: create(:token) }.merge(**attrs))
  end

  def sb_project(account = create(:account), **attrs)
    project(account, { title: 'Swarmbot', payment_type: 'project_token', token: create(:token) }.merge(**attrs))
  end

  def project(account = create(:account_with_auth), **attrs)
    defaults = {
      title: 'Uber for Cats',
      description: 'We are going to build amazing',
      tracker: 'https://github.com/example/uber_for_cats',
      account: account,
      legal_project_owner: 'UberCatz Inc',
      require_confidentiality: false,
      exclusive_contributions: false,
      visibility: 'member',
      long_id: SecureRandom.hex(20),
      maximum_tokens: 1_000_000_000,
      token: create(:token),
      mission: create(:mission),
      square_image: Refile::FileDouble.new('dummy_image', 'image.png', content_type: 'image/png'),
      panoramic_image: Refile::FileDouble.new('dummy_image', 'image.png', content_type: 'image/png')
    }
    Project.new(defaults.merge(attrs))
  end

  def token(**attrs)
    defaults = {
      name: "Token-#{SecureRandom.hex(20)}",
      symbol: "TKN#{SecureRandom.hex(20)}",
      logo_image: Refile::FileDouble.new('dummy_image', 'image.png', content_type: 'image/png')
    }
    Token.new(defaults.merge(attrs))
  end

  def comakery_token(**attrs)
    defaults = {
      name: "ComakeryToken-#{SecureRandom.hex(20)}",
      symbol: "XYZ#{SecureRandom.hex(20)}",
      logo_image: dummy_image,
      coin_type: :comakery,
      decimal_places: 18,
      ethereum_network: :ropsten,
      ethereum_contract_address: '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37'
    }
    Token.new(defaults.merge(attrs))
  end

  def interest(**attrs)
    params = {
      protocol: 'Moms protocol',
      account: create(:account),
      project: create(:project),
      specialty: create(:specialty)
    }.merge(attrs)

    Interest.new(params)
  end

  def channel(**attrs)
    defaults = {
      team: create(:team),
      project: create(:project),
      channel_id: SecureRandom.hex(5),
      name: 'general'
    }
    Channel.new defaults.merge(attrs)
  end

  def award_type(**attrs)
    defaults = {
      name: 'Contribution',
      goal: 'none',
      description: 'none',
      state: 'public'
    }
    attrs[:project] = create(:project) unless attrs[:project]
    AwardType.new(defaults.merge(attrs))
  end

  def award_ready(**attrs)
    params = {
      name: 'none',
      description: 'none',
      why: 'none',
      requirements: 'none',
      proof_link: 'http://nil',
      amount: 50
    }.merge(attrs)

    params[:award_type] ||= create(:award_type)
    params[:issuer] ||= create(:account)
    params[:account] ||= create(:account)

    Award.new(params)
  end

  def project_with_ready_task(**attrs)
    params = {
      name: 'none',
      description: 'none',
      why: 'none',
      requirements: 'none',
      amount: 50
    }.merge(attrs)

    params[:project] ||= create(:project, account: create(:account))
    project = params.delete(:project)
    params[:issuer] ||= create(:account)
    params[:award_type] ||= create(:award_type, project: project)

    award = Award.new(params)
    award.save!
    project
  end

  def award(**attrs)
    params = {
      name: 'none',
      description: 'none',
      why: 'none',
      requirements: 'none',
      proof_link: 'http://nil',
      proof_id: 'abc123',
      status: 'accepted',
      message: 'Great work',
      quantity: 1,
      amount: 50,
      submission_url: 'http://dummy',
      submission_comment: 'comment',
      issuer: create(:account)
    }.merge(attrs)

    params[:award_type] ||= create(:award_type, project: create(:project, account: params[:issuer]))
    params[:account] ||= create(:account)

    Award.new(params)
  end

  def transfer(**attrs)
    params = {
      name: 'Bought',
      source: :bought,
      description: 'Investment',
      why: '–',
      requirements: '–',
      status: :accepted,
      quantity: 1,
      amount: 50,
      issuer: create(:account),
      account: create(:account)
    }.merge(attrs)

    params[:award_type] ||= create(:project, account: params[:issuer]).default_award_type

    Award.new(params)
  end

  def slack(authentication = create(:authentication))
    Comakery::Slack.new(authentication)
  end

  def team(**attrs)
    defaults = {
      team_id: SecureRandom.hex(5),
      name: "Team-#{SecureRandom.hex(2)}",
      provider: 'slack',
      domain: "test-app-#{SecureRandom.hex(2)}"
    }
    Team.new(defaults.merge(attrs))
  end

  def valid_password
    'a password'
  end

  def mission(**attrs)
    defaults = {
      name: 'test1',
      subtitle: 'test1',
      description: 'test1',
      image: Refile::FileDouble.new('dummy_image', 'image.png', content_type: 'image/png'),
      logo: Refile::FileDouble.new('dummy_logo', 'logo.png', content_type: 'image/png')
    }
    Mission.new(defaults.merge(attrs))
  end

  def active_whitelabel_mission
    create(:mission, whitelabel: true, whitelabel_domain: 'test.host', whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key))
  end

  def api_public_key
    'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA='
  end

  def api_private_key
    'eodjQfDLTyNCBnz+MORHW0lOKWZnCTyPDTFcwAdVRyQ7vNMfjEecPWNEqF4FOuk03bgWDV10vwMcqL/OBUJWkA=='
  end

  def api_key
    '28ieQrVqi5ZQXd77y+pgiuJGLsFfwkWO'
  end

  def api_signed_request(data, path, method, host = 'test.host')
    Comakery::APISignature.new('body' => {
      'data' => data.is_a?(Hash) ? data.deep_stringify_keys : data,
      'url' => "http://#{host}#{path}",
      'method' => method
    }).sign(build(:api_private_key))
  end

  def ethereum_address_1
    '0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB'
  end

  def ethereum_address_2
    '0xB4252b39f8506A711205B0b1C4170f0034065b46'
  end

  def ethereum_contract_address
    '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37'
  end

  def eth_client(**attrs)
    network = attrs[:network] || :ropsten

    Comakery::Eth.new(
      network
    )
  end

  def eth_tx(**attrs)
    network = attrs[:network] || :ropsten
    hash = attrs[:hash] || '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d'

    Comakery::EthTx.new(
      network,
      hash
    )
  end

  def erc20_transfer(**attrs)
    network = attrs[:network] || :ropsten
    hash = attrs[:hash] || '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d'

    Comakery::Erc20Transfer.new(
      network,
      hash
    )
  end

  def erc20_mint(**attrs)
    network = attrs[:network] || :ropsten
    hash = attrs[:hash] || '0x02286b586b53784715e7eda288744e1c14a5f2d691d43160d4e3c4d5f8825ad0'

    Comakery::Erc20Mint.new(
      network,
      hash
    )
  end

  def erc20_burn(**attrs)
    network = attrs[:network] || :ropsten
    hash = attrs[:hash] || '0x1007e9116efab368169683b81ae576bd48e168bef2be1fea5ef096ccc9e5dcc0'

    Comakery::Erc20Burn.new(
      network,
      hash
    )
  end

  def erc20_contract(**attrs)
    token = create(
      :token,
      coin_type: :comakery,
      ethereum_network: :ropsten,
      ethereum_contract_address: build(:ethereum_contract_address),
      symbol: 'DUM',
      decimal_places: 0
    )

    contract_address = attrs[:contract_address] || token.ethereum_contract_address
    abi = attrs[:abi] || token.abi
    network = attrs[:network] || token.ethereum_network
    nonce = attrs[:nonce] || rand(1_000_000)

    VCR.use_cassette("infura/#{network}/#{contract_address}/contract_init") do
      Comakery::Erc20.new(
        contract_address,
        abi,
        network,
        nonce
      )
    end
  end
end

def mom
  @mom ||= Mom.new
end

def build(thing, *args)
  mom.send(thing, *args)
end

def create(thing, *args)
  mom.send(thing, *args).tap(&:save!)
end

def dummy_image
  Refile::FileDouble.new('dummy_image', 'dummy_image.png', content_type: 'image/png')
end
