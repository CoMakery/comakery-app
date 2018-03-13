class Mom
  def account(**attrs)
    defaults = {
      email: "me+#{Random.new.urlsafe_base64}@example.com",
      password: valid_password
    }
    Account.new(defaults.merge(attrs))
  end

  def account_with_auth(**attrs)
    account(**attrs).tap { |a| create(:authentication, account: a) }
  end

  def account_role(account, role)
    AccountRole.new account: account, role: role
  end

  def admin_role
    role name: 'Admin', key: Role::ADMIN_ROLE_KEY
  end

  def cc_authentication(**attrs)
    defaults = { slack_team_id: 'citizencode' }
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

  def beta_signup(**attrs)
    BetaSignup.new(**attrs)
  end

  def cc_project(account = create(:cc_authentication).account, **attrs)
    project(account, { slack_team_id: 'citizencode', title: 'Citizen Code' }.merge(**attrs))
  end

  def sb_project(account = create(:account), **attrs)
    project(account, { title: 'Swarmbot', payment_type: 'project_token' }.merge(**attrs))
  end

  def project(account = create(:account_with_auth), **attrs)
    defaults = {
      title: 'Uber for Cats',
      description: 'We are going to build amazing',
      tracker: 'https://github.com/example/uber_for_cats',
      slack_channel: 'slack_channel',
      account: account,
      royalty_percentage: 5.9,
      maximum_royalties_per_month: 10_000,
      legal_project_owner: 'UberCatz Inc',

      maximum_tokens: 10_000_000
    }
    Project.new(defaults.merge(attrs))
  end

  def award_type(**attrs)
    defaults = {
      amount: 1337,
      name: 'Contribution'
    }
    attrs[:project] = create(:project) unless attrs[:project]
    AwardType.new(defaults.merge(attrs))
  end

  def award(account = create(:account), **attrs)
    params = {
      account: account,
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

  def project_payment(quantity_redeemed: 1, payee_auth: create(:authentication), project: create(:project))
    project
      .payments
      .new_with_quantity(quantity_redeemed: quantity_redeemed,
                         payee_auth: payee_auth)
  end

  def slack(authentication = create(:authentication))
    Comakery::Slack.new(authentication)
  end

  def role(name: 'A Role', key: nil)
    Role.new name: name, key: (key || name)
  end

  def team(**attrs)
    defaults = {
      team_id: '12EDF',
      name: 'Team',
      provider: 'Slack',
      domain: 'test-app'
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
