require 'refile/file_double'

class Mom
  def account(**attrs)
    defaults = {
      email: "me+#{SecureRandom.hex(20)}@example.com",
      first_name: 'Account',
      last_name: SecureRandom.hex(20),
      date_of_birth: '1990/01/01',
      country: 'United States of America',
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
      mission: create(:mission)
    }
    Project.new(defaults.merge(attrs))
  end

  def token(**attrs)
    defaults = {
      name: "Token-#{SecureRandom.hex(20)}",
      symbol: "TKN#{SecureRandom.hex(20)}"
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
      published: true
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
      submission_url: 'url',
      submission_comment: 'comment',
      issuer: create(:account)
    }.merge(attrs)

    params[:award_type] ||= create(:award_type, project: create(:project, account: params[:issuer]))
    params[:account] ||= create(:account)

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
