module SlackStubs
  def stub_slack_user_list(members = [])
    stub_request(:post, 'https://slack.com/api/users.list').to_return(body: { "ok": true, "members": members }.to_json)
  end

  def slack_user_from_auth(auth)
    auth_team = AuthenticationTeam.find_by(authentication: auth)
    {
      "id": auth.uid,
      "team_id": auth_team&.team_id,
      "name": auth.account.decorate.name,
      "deleted": false,
      "profile": {
        "first_name": auth.account.first_name,
        "last_name": auth.account.last_name,
        "real_name": auth.account.decorate.name,
        "real_name_normalized": auth.account.decorate.name,
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
    response = '[{"icon": null, "id": "team_id", "name": "discord guild", "permissions": 40}]'
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

  def stub_discord_user
    response = '{"username": "jason", "discriminator": "4088", "id": "123"}'
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

  def stub_token_symbol(contract_address, symbol)
    stub_request(:get, "https://api.etherscan.io/api?action=tokentx&contractaddress=#{contract_address}&module=account&offset=1&page=1")
      .with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: "{\"status\":\"1\",\"message\":\"OK\",\"result\":[{\"blockNumber\":\"5409817\",\"timeStamp\":\"1523286162\",\"hash\":\"0x9f6fbd761fa37fc6b5d6a116c5fe1700de05d2453ae96151ed6803943cafa993\",\"nonce\":\"1\",\"blockHash\":\"0x789d86c39bc82e37508ba4f3b1ca1dc1472b7a72144e1755d9810cf5688697d6\",\"from\":\"0x0000000000000000000000000000000000000000\",\"contractAddress\":\"0xa8112e56eb96bd3da7741cfea0e3cbd841fc009d\",\"to\":\"0x6d625563094a506b1dda21c57d7ac97ea52a4058\",\"value\":\"21000000000000000000000000000\",\"tokenName\":\"翡翠币\",\"tokenSymbol\":\"#{symbol}\",\"tokenDecimal\":\"18\",\"transactionIndex\":\"91\",\"gas\":\"1501234\",\"gasPrice\":\"2000000000\",\"gasUsed\":\"1290697\",\"cumulativeGasUsed\":\"5406373\",\"input\":\"0xfb1a63e400000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000043dacaf91c1a84ff080000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000009e7bfa1e7bfa0e5b881000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044643424200000000000000000000000000000000000000000000000000000000\",\"confirmations\":\"492920\"}]}", headers: {})
  end
end
