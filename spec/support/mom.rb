class Mom
  def account(**attrs)
    defaults = {
        email: Faker::Internet.safe_email,
        password: valid_password
    }
    Account.new(defaults.merge(attrs))
  end

  def account_role(account, role)
    AccountRole.new account: account, role: role
  end

  def admin_role
    role name: 'Admin', key: Role::ADMIN_ROLE_KEY
  end

  def authentication(**attrs)
    defaults = {
        provider: "slack",
        uid: "this is a generic uid",
        slack_token: "slack token",
        slack_user_id: "slack user id",
        slack_team_name: "Slack Team",
        slack_team_id: "citizen code id",
    }
    Authentication.new(defaults.merge(attrs))
  end

  def project(**attrs)
    defaults = {
        title: "Uber for Cats",
        description: "We are going to build amazing",
        tracker: "https://github.com/example/uber_for_cats",
        slack_team_id: "citizen code id",
    }
    Project.new(defaults.merge(attrs))
  end

  def role(name: 'A Role', key: nil)
    Role.new name: name, key: (key || name)
  end

  def valid_password
    'a password'
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
