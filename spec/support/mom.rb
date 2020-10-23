require 'refile/file_double'
require 'webmock/rspec'
include WebMock::API # rubocop:todo Style/MixinUsage

WebMock.enable!

class Mom
  def account(**attrs)
    defaults = {
      email: "me+#{SecureRandom.hex(20)}@example.com",
      first_name: 'Eva',
      last_name: 'Smith',
      nickname: "hunter-#{SecureRandom.hex(20)}",
      date_of_birth: '1990/01/01',
      country: 'United States of America',
      specialty: create(:specialty),
      password: valid_password
    }
    Account.new(defaults.merge(attrs))
  end

  def wallet(**attrs)
    defaults = {
      _blockchain: :bitcoin,
      account: create(:account),
      address: bitcoin_address_1
    }
    Wallet.new(defaults.merge(attrs))
  end

  def balance(**attrs)
    defaults = {
      wallet: create(:wallet),
      token: create(:token)
    }
    Balance.new(defaults.merge(attrs))
  end

  def ore_id(**attrs)
    defaults = {
      account: create(:account)
    }
    OreId.new(defaults.merge(attrs))
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
    token = attrs[:token] || create(:comakery_dummy_token)

    defaults = {
      token: token,
      name: "RegGroup #{SecureRandom.hex(20)}",
      blockchain_id: RegGroup.maximum(:id).to_i + 1000
    }
    RegGroup.new(defaults.merge(attrs))
  end

  def transfer_type(**attrs)
    project = attrs[:project] || create(:project)

    defaults = {
      project: project,
      name: "Type #{SecureRandom.hex(5)}"
    }
    TransferType.new(defaults.merge(attrs))
  end

  def transfer_rule(**attrs)
    token = attrs[:token] || create(:comakery_dummy_token)

    defaults = {
      token: token,
      sending_group: create(:reg_group, token: token),
      receiving_group: create(:reg_group, token: token),
      lockup_until: 1.day.ago
    }
    TransferRule.new(defaults.merge(attrs))
  end

  def account_token_record(**attrs)
    token = attrs[:token] || build(:comakery_dummy_token)

    account = attrs[:account] || create(
      :account
    )

    account.wallets.find_by(_blockchain: token._blockchain) || create(
      :wallet,
      account: account,
      _blockchain: token._blockchain,
      address: attrs[:address] || build(:ethereum_address_2)
    )

    attrs.delete(:address)

    defaults = {
      account: account,
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
    token = attrs[:token] || create(:comakery_dummy_token)
    attrs.delete(:token)

    award = blockchain_transaction__award(attrs.merge(token: token))
    attrs.delete(:award)

    defaults = {
      blockchain_transactable: award,
      amount: 1,
      source: build(:ethereum_address_1),
      nonce: token._token_type_token? ? rand(1_000_000) : nil,
      status: :created,
      status_message: 'dummy'
    }

    VCR.use_cassette("infura/#{token._blockchain}/#{token.contract_address}/contract_init") do
      BlockchainTransaction.create!(defaults.merge(attrs))
    end
  end

  def blockchain_transaction_transfer_rule(**attrs)
    token = attrs[:token] || create(:comakery_dummy_token)
    attrs.delete(:token)

    defaults = {
      blockchain_transactable: create(:transfer_rule),
      amount: 1,
      source: build(:ethereum_address_1),
      nonce: token._token_type_token? ? rand(1_000_000) : nil,
      status: :created,
      status_message: 'dummy'
    }

    VCR.use_cassette("infura/#{token._blockchain}/#{token.contract_address}/contract_init") do
      BlockchainTransactionTransferRule.create!(defaults.merge(attrs))
    end
  end

  def blockchain_transaction_account_token_record(**attrs)
    token = attrs[:token] || create(:comakery_dummy_token)
    attrs.delete(:token)

    defaults = {
      blockchain_transactable: create(:account_token_record),
      amount: 1,
      source: build(:ethereum_address_1),
      nonce: token._token_type_token? ? rand(1_000_000) : nil,
      status: :created,
      status_message: 'dummy'
    }

    VCR.use_cassette("infura/#{token._blockchain}/#{token.contract_address}/contract_init") do
      BlockchainTransactionAccountTokenRecord.create!(defaults.merge(attrs))
    end
  end

  def blockchain_transaction__award(**attrs) # rubocop:todo Metrics/CyclomaticComplexity
    project = attrs[:award]&.project || create(
      :project,
      token: attrs[:token]
    )

    account = attrs[:account] || create(
      :account
    )

    account.wallets.find_by(_blockchain: project.token._blockchain) || create(
      :wallet,
      account: account,
      _blockchain: project.token._blockchain,
      address: attrs[:destination] || build(:ethereum_address_2)
    )

    attrs[:award] || create(
      :award,
      amount: attrs[:amount] || 1,
      status: :accepted,
      account: account,
      award_type: create(
        :award_type,
        project: project
      ),
      transfer_type: create(
        :transfer_type,
        project: project
      )
    )
  end

  def blockchain_transaction_dag(**attrs)
    token = attrs[:token] || create(:dag_token)
    attrs.delete(:token)

    award = blockchain_transaction__award_dag(attrs.merge(token: token))
    attrs.delete(:award)

    defaults = {
      blockchain_transactable: award,
      amount: 1,
      source: build(:constellation_address_1),
      nonce: nil,
      status: :created,
      status_message: 'dummy'
    }

    BlockchainTransaction.create!(defaults.merge(attrs))
  end

  def blockchain_transaction__award_dag(**attrs) # rubocop:todo Metrics/CyclomaticComplexity
    project = attrs[:award]&.project || create(
      :project,
      token: attrs[:token]
    )

    account = attrs[:account] || create(
      :account
    )

    account.wallets.find_by(_blockchain: project.token._blockchain) || create(
      :wallet,
      account: account,
      _blockchain: project.token._blockchain,
      address: attrs[:destination] || build(:constellation_address_2)
    )

    attrs[:award] || create(
      :award,
      amount: attrs[:amount] || 1,
      status: :accepted,
      account: account,
      award_type: create(
        :award_type,
        project: project
      ),
      transfer_type: create(
        :transfer_type,
        project: project
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
    @@authentication_count ||= 0 # rubocop:todo Style/ClassVars
    @@authentication_count += 1 # rubocop:todo Style/ClassVars
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
      maximum_tokens: 1_000_000_000_000_000_000,
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
      logo_image: Refile::FileDouble.new('dummy_image', 'image.png', content_type: 'image/png'),
      token_frozen: false
    }

    t = Token.new(defaults.merge(attrs))

    VCR.use_cassette("#{t.blockchain.explorer_api_host}/contract/#{t.contract_address}/token_init") do
      t.save!
    end

    t
  end

  def comakery_token(**attrs)
    defaults = {
      name: "ComakeryToken-#{SecureRandom.hex(20)}",
      symbol: "XYZ#{SecureRandom.hex(20)}",
      logo_image: dummy_image,
      _token_type: :comakery_security_token,
      decimal_places: 18,
      _blockchain: :ethereum_ropsten,
      contract_address: '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37',
      token_frozen: false
    }
    t = Token.new(defaults.merge(attrs))

    VCR.use_cassette("#{t.blockchain.explorer_api_host}/contract/#{t.contract_address}/token_init") do
      t.save!
    end

    t
  end

  def comakery_dummy_token(**attrs)
    defaults = {
      name: "ComakeryDummyToken-#{SecureRandom.hex(20)}",
      symbol: "DUM#{SecureRandom.hex(20)}",
      logo_image: dummy_image,
      _blockchain: :ethereum_ropsten,
      contract_address: '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37',
      _token_type: :comakery_security_token,
      decimal_places: 0,
      token_frozen: false
    }
    t = Token.new(defaults.merge(attrs))

    VCR.use_cassette("#{t.blockchain.explorer_api_host}/contract/#{t.contract_address}/token_init") do
      t.save!
    end

    t
  end

  def dag_token(**attrs)
    defaults = {
      logo_image: dummy_image,
      _token_type: :dag,
      _blockchain: :constellation_test
    }
    t = Token.new(defaults.merge(attrs))

    VCR.use_cassette("#{t.blockchain.explorer_api_host}/contract/#{t.contract_address}/token_init") do
      t.save!
    end

    t
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
    params[:transfer_type] ||= create(:transfer_type, project: params[:award_type].project)

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
    params[:transfer_type] ||= create(:transfer_type, project: params[:award_type].project)

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
    params[:account] ||= params[:email] ? nil : create(:account)
    params[:transfer_type] ||= create(:transfer_type, project: params[:award_type].project)

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
    params[:transfer_type] ||= create(:transfer_type, project: params[:award_type].project)

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
    host = attrs[:host] || 'ropsten.infura.io'

    Comakery::Eth.new(
      host
    )
  end

  def eth_tx(**attrs)
    host = attrs[:host] || 'ropsten.infura.io'
    hash = attrs[:hash] || '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d'

    # From:
    # 0x66ebd5cdf54743a6164b0138330f74dce436d842
    # Contract:
    # 0x1d1592c28fff3d3e71b1d29e31147846026a0a37
    # To:
    # 0x8599d17ac1cec71ca30264ddfaaca83c334f8451
    # Amount:
    # 100

    Comakery::Eth::Tx.new(
      host,
      hash
    )
  end

  def erc20_transfer(**attrs)
    host = attrs[:host] || 'ropsten.infura.io'
    hash = attrs[:hash] || '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d'

    # From:
    # 0x66ebd5cdf54743a6164b0138330f74dce436d842
    # Contract:
    # 0x1d1592c28fff3d3e71b1d29e31147846026a0a37
    # To:
    # 0x8599d17ac1cec71ca30264ddfaaca83c334f8451
    # Amount:
    # 100

    Comakery::Eth::Tx::Erc20::Transfer.new(
      host,
      hash
    )
  end

  def erc20_mint(**attrs)
    host = attrs[:host] || 'ropsten.infura.io'
    hash = attrs[:hash] || '0x02286b586b53784715e7eda288744e1c14a5f2d691d43160d4e3c4d5f8825ad0'

    Comakery::Eth::Tx::Erc20::Mint.new(
      host,
      hash
    )
  end

  def erc20_burn(**attrs)
    host = attrs[:host] || 'ropsten.infura.io'
    hash = attrs[:hash] || '0x1007e9116efab368169683b81ae576bd48e168bef2be1fea5ef096ccc9e5dcc0'

    Comakery::Eth::Tx::Erc20::Burn.new(
      host,
      hash
    )
  end

  def security_token_set_allow_group_transfer(**attrs)
    host = attrs[:host] || 'ropsten.infura.io'
    hash = attrs[:hash] || '0xdd2d8399654bf4b12308cacd013c63343fdd474eea902ff8738138a34c4ec582'

    # Inputs:
    # 0	from	uint256	0
    # 1	to	uint256	0
    # 2	lockedUntil	uint256	1586908800
    #
    # From:
    # 0x75f538eafdb14a2dc9f3909aa1e0ea19727ff44b

    Comakery::Eth::Tx::Erc20::SecurityToken::SetAllowGroupTransfer.new(
      host,
      hash
    )
  end

  def security_token_set_address_permissions(**attrs)
    host = attrs[:host] || 'ropsten.infura.io'
    hash = attrs[:hash] || '0x9a5af207b43c656531363d46ed899bef73445e4a31cc65832df6ee7b9aad948d'

    # Inputs:
    # 0	addr	address	8599d17ac1cec71ca30264ddfaaca83c334f8451
    # 1	groupID	uint256	0
    # 2	timeLockUntil	uint256	86400
    # 3	maxBalance	uint256	100000000000000000000000000
    # 4	status	bool	false
    #
    # From:
    # 0x8599d17ac1cec71ca30264ddfaaca83c334f8451

    Comakery::Eth::Tx::Erc20::SecurityToken::SetAddressPermissions.new(
      host,
      hash
    )
  end

  def erc20_contract(**attrs)
    token = create(
      :token,
      _token_type: :comakery_security_token,
      _blockchain: :ethereum_ropsten,
      contract_address: build(:ethereum_contract_address),
      symbol: 'DUM',
      decimal_places: 0
    )

    contract_address = attrs[:contract_address] || token.contract_address
    abi = attrs[:abi] || token.abi
    host = attrs[:host] || token.blockchain.explorer_api_host
    nonce = attrs[:nonce] || rand(1_000_000)

    VCR.use_cassette("#{host}/contract/#{contract_address}/contract_init") do
      Comakery::Eth::Contract::Erc20.new(
        contract_address,
        abi,
        host,
        nonce
      )
    end
  end

  def bitcoin_address_1
    '3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt'
  end

  def constellation_address_1
    'DAG8LvRqfJchUjkw5Fpm3DohFqgXhqeqRAVUWKKY'
  end

  def constellation_address_2
    'DAG8PU6Np9zrCfNEcq5bnEco6NdYKtcKgTDnZYwp'
  end

  def dag_tx(**attrs)
    host = attrs[:host] || :constellation_test
    hash = attrs[:hash] || '2dd4f39300c5536005170acbb2eb8bfacf15c0b1d78541c7922813319cfc786d'

    stub_constellation_request(
      host,
      hash,
      'hash' => '2dd4f39300c5536005170acbb2eb8bfacf15c0b1d78541c7922813319cfc786d',
      'amount' => 0,
      'receiver' => 'DAG8LvRqfJchUjkw5Fpm3DohFqgXhqeqRAVUWKKY',
      'sender' => 'DAG8PU6Np9zrCfNEcq5bnEco6NdYKtcKgTDnZYwp'
    )

    Comakery::Dag::Tx.new(
      host,
      hash
    )
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
