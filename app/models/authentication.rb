class Authentication < ActiveRecord::Base
  belongs_to :account

  class MissingAuthParamException < Exception; end

  def self.find_or_create_from_auth_hash!(auth_hash)
    auth_hash = auth_hash.to_h
    provider = auth_hash['provider']
    uid = auth_hash['uid']
    name = get_name(auth_hash)
    slack_user_id = auth_hash.dig('info', 'user_id')
    slack_team_id = auth_hash.dig('info', 'team_id')
    slack_team_name = auth_hash.dig('info', 'team')
    slack_token = auth_hash.dig('credentials', 'token')
    email_address = auth_hash.dig('extra', 'user_info', 'user', 'profile', 'email')

    unless provider && email_address && name && slack_team_id && slack_team_name && slack_user_id && slack_token
      raise MissingAuthParamException.new({provider: provider,
                                          email_address: email_address,
                                          name: name,
                                          slack_team_id: slack_team_id,
                                          slack_team_name: slack_team_name,
                                          slack_user_id: slack_user_id,
                                          slack_token: slack_token}.to_json)
    end

    account = Account.find_or_initialize_by(email: email_address)
    account.update!(name: name)

    # find the "slack" authentication if exists
    authentication = Authentication.find_or_initialize_by(provider: provider)

    # update it, possibly logging them out of any other slack teams, and into this one
    authentication.update!(
      account_id: account.id,
      slack_user_id: slack_user_id,
      uid: uid,
      slack_team_id: slack_team_id,
      slack_team_name: slack_team_name,
      slack_token: slack_token
    )
    account
  end

  def self.get_name(auth_hash)
    auth_hash.dig('info', 'name').presence || auth_hash.dig('info', 'nickname').presence || auth_hash.dig('info', 'user')
  end

end
