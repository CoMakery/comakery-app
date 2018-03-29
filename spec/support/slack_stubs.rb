module SlackStubs
  def stub_slack_user_list(members = [])
    stub_request(:post, 'https://slack.com/api/users.list').to_return(body: { "ok": true, "members": members }.to_json)
  end

  def slack_user_from_auth(auth)
    auth_team = AuthenticationTeam.find_by(authentication: auth)
    {
      "id": auth.uid,
      "team_id": auth_team&.team_id,
      "name": auth.account.name,
      "deleted": false,
      "profile": {
        "first_name": auth.account.first_name,
        "last_name": auth.account.last_name,
        "real_name": auth.account.name,
        "real_name_normalized": auth.account.name,
        "email": auth.account.email
      }
    }
  end

  def sb_slack_user(first_name: 'Bob', last_name: 'Johnson', team_id: 'T9999S99P', user_id: 'U9999UVMH')
    slack_user(team_id: 'swarmbot', first_name: first_name, last_name: last_name, user_id: user_id)
  end

  def slack_user(first_name: 'Bob', last_name: 'Johnson', team_id: 'T9999S99P', user_id: 'U9999UVMH')
    full_name = [first_name, last_name].compact.join(' ')
    machine_name = full_name.delete(' ').downcase
    {
      "id": user_id,
      "team_id": team_id,
      "name": machine_name,
      "deleted": false,
      "profile": {
        "first_name": first_name,
        "last_name": last_name,
        "real_name": full_name,
        "real_name_normalized": full_name,
        "email": "#{machine_name}@example.com"
      }
    }
  end

  def stub_slack_channel_list
    stub_request(:post, 'https://slack.com/api/channels.list').to_return(body: { ok: true, channels: [{ id: 'channel id', name: 'a-channel-name', num_members: 3 }] }.to_json)
  end

  def stub_discord_guilds
    response = '[{"icon": null, "id": "team_id", "name": "discord guild"}]'
    RestClient.stub(:get) { response }
  end

  def stub_discord_channels
    response = '[{"parent_id": null, "id": "parent_id", "name": "Text Channels"},{"parent_id": "parent_id", "id": "channel_id", "name": "general"}]'
    RestClient.stub(:get) { response }
  end

  def stub_discord_members
    response = '[{"user": {"id": "123", "username": "jason", "name": "Jason"}},{"user": {"id": "234", "username": "bob", "name": "Bob"}}]'
    RestClient.stub(:get) { response }
  end

  def stub_discord_webhooks
    response = '[{"id": "123", "name": "Comakery"}]'
    RestClient.stub(:get) { response }
    RestClient.stub(:post) { true }
  end

  def stub_create_discord_webhooks
    response = '[{"id": "123", "name": "another webhook"}]'
    RestClient.stub(:get) { response }
    RestClient.stub(:post) { '{"id": "123", "name": "Comakery"}' }
  end
end
