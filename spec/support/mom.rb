class Mom
  def account(**attrs)
    defaults = {
      email: "me+#{Random.new.urlsafe_base64}@example.com",
      first_name: 'Account',
      last_name: (1..100).to_a.sample,
      date_of_birth: '2000/01/01',
      country: 'United States of America',
      password: valid_password
    }
    Account.new(defaults.merge(attrs))
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
    project(account, { title: 'Citizen Code' }.merge(**attrs))
  end

  def sb_project(account = create(:account), **attrs)
    project(account, { title: 'Swarmbot', payment_type: 'project_token' }.merge(**attrs))
  end

  def project(account = create(:account_with_auth), **attrs)
    defaults = {
      title: 'Uber for Cats',
      description: 'We are going to build amazing',
      tracker: 'https://github.com/example/uber_for_cats',
      account: account,
      royalty_percentage: 5.9,
      maximum_royalties_per_month: 10_000,
      legal_project_owner: 'UberCatz Inc',
      long_id: SecureRandom.hex(20),
      maximum_tokens: 10_000_000
    }
    Project.new(defaults.merge(attrs))
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
      amount: 1337,
      name: 'Contribution'
    }
    attrs[:project] = create(:project) unless attrs[:project]
    AwardType.new(defaults.merge(attrs))
  end

  def award(**attrs)
    params = {
      issuer: create(:account),
      description: 'Great work',
      proof_id: 'abc123',
      quantity: 1,
      unit_amount: 50,
      total_amount: 50
    }.merge(attrs)

    params[:award_type] ||= create(:award_type, amount: params[:unit_amount])

    params[:unit_amount] = params[:award_type].amount
    params[:total_amount] = params[:award_type].amount * params[:quantity]

    Award.new(params)
  end

  def payment(currency: 'USD', **attrs)
    Payment.new(currency: currency, **attrs)
  end

  def project_payment(quantity_redeemed: 1, account: create(:account), project: create(:project))
    project
      .payments
      .new_with_quantity(quantity_redeemed: quantity_redeemed,
                         account: account)
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

  def revenue(project: create(:project), amount: 10, currency: 'USD')
    Revenue.new amount: amount,
                currency: currency,
                project: project,
                recorded_by: project.account
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
