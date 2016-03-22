class Mom
  def cc_account(**attrs)
    account(**attrs).tap{|a| create(:cc_authentication, account: a) }
  end

  def sb_account(**attrs)
    account(**attrs).tap{|a| create(:sb_authentication, account: a) }
  end

  def account(**attrs)
    @@account_count ||= 0
    @@account_count += 1
    defaults = {
        email: "me+#{@@account_count}@example.com",
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

  def cc_authentication(**attrs)
    defaults = {slack_team_id: "citizencode"}
    defaults[:account] = cc_account unless attrs.has_key?(:account)
    authentication(defaults.merge(attrs))
  end

  def sb_authentication(**attrs)
    defaults = {slack_team_id: "swarmbot"}
    defaults[:account] = cc_account unless attrs.has_key?(:account)
    authentication(defaults.merge(attrs))
  end

  def authentication(**attrs)
    @@authentication_count ||= 0
    @@authentication_count += 1
    defaults = {
        provider: "slack",
        slack_token: "slack token",
        slack_user_id: "slack user id #{@@authentication_count}",
        slack_team_name: "Slack Team",
        slack_team_image_34_url: "https://slack.example.com/team-image-34-px.jpg",
        slack_team_image_132_url: "https://slack.example.com/team-image-132-px.jpg",
        slack_team_id: "citizen code id",
        slack_user_name: "johndoe"
    }
    defaults[:account] = create(:account) unless attrs.has_key?(:account)
    defaults[:slack_first_name] = "John" unless attrs.has_key?(:slack_first_name) && attrs[:slack_first_name] == nil
    defaults[:slack_last_name] = "Doe" unless attrs.has_key?(:slack_last_name) && attrs[:slack_last_name] == nil
    Authentication.new(defaults.merge(attrs))
  end


  def cc_project(owner_account = create(:cc_authentication), **attrs)
    project(owner_account, {slack_team_id: "citizencode"}.merge(**attrs))
  end

  def sb_project(owner_account = create(:sb_authentication), **attrs)
    project(owner_account, {slack_team_id: "swarmbot"}.merge(**attrs))
  end

  def project(owner_account = create(:account), **attrs)
    defaults = {
        title: "Uber for Cats",
        description: "We are going to build amazing",
        tracker: "https://github.com/example/uber_for_cats",
        slack_team_id: "citizen code id",
        slack_channel: "slack_channel",
        slack_team_name: "Citizen Code",
        slack_team_image_34_url: "https://slack.example.com/team-image-34-px.jpg",
        slack_team_image_132_url: "https://slack.example.com/team-image-132-px.jpg",
        owner_account: owner_account
    }
    Project.new(defaults.merge(attrs))
  end

  def award_type(**attrs)
    defaults = {
        amount: 1337,
        name: "Contribution"
    }
    attrs[:project] = create(:project) unless attrs[:project]
    AwardType.new(defaults.merge(attrs))
  end

  def award(authentication = create(:authentication), issuer = create(:account), **attrs)
    defaults = {
        authentication: authentication,
        issuer: issuer,
        description: "Great work",
    }
    defaults[:award_type] = create(:award_type) unless attrs[:award_type]
    Award.new(defaults.merge(attrs))
  end

  def slack(authentication = create(:authentication))
    Comakery::Slack.new(authentication)
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
