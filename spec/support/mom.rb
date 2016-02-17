class Mom
  def account(
    email: Faker::Internet.safe_email,
    password: valid_password
  )
    Account.new email: email
  end

  def account_role(account, role)
    AccountRole.new account: account, role: role
  end

  def admin_role
    role name: 'Admin', key: Role::ADMIN_ROLE_KEY
  end

  def authentication(provider:"slack", uid: "this is a generic uid", account_id:)
    Authentication.new(provider: provider, uid: uid, account_id: account_id)
  end

  def project(text = "Uber for Cats")
    Project.new title: text, description: "We are going to build #{text}", repo: "https://github.com/example/#{text.parameterize}"
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
