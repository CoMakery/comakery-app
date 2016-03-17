module SlackStubs
  def stub_slack_user_list
    stub_request(:post, "https://slack.com/api/users.list").to_return(body: {"ok": true, "members": []}.to_json)
  end

  def stub_slack_channel_list
    stub_request(:post, "https://slack.com/api/channels.list").to_return(body: {ok: true, channels: [{id: "channel id", name: "a channel name", num_members: 3}]}.to_json)
  end
end