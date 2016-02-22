class Authentication < ActiveRecord::Base
  belongs_to :account

  class MissingAuthParamException < Exception; end

  def self.find_or_create_from_auth_hash!(auth_hash)
    auth_hash = auth_hash.to_h
    provider = auth_hash['provider']
    uid = auth_hash['uid']
    slack_user_id = auth_hash.dig('info', 'user_id')
    slack_team_id = auth_hash.dig('info', 'team_id')
    slack_team_name = auth_hash.dig('info', 'team')
    slack_token = auth_hash.dig('credentials', 'token')
    email_address = auth_hash.dig('extra', 'user_info', 'user', 'profile', 'email')

    raise MissingAuthParamException.new unless provider && email_address && slack_team_id && slack_team_name && slack_user_id && slack_token

    account = Account.find_or_create_by!(email: email_address)

    authentication = Authentication.find_or_initialize_by(provider: provider,
                                                          account_id: account.id,
                                                          slack_user_id: slack_user_id)
    authentication.update!(uid: uid, slack_team_id: slack_team_id, slack_team_name: slack_team_name, slack_token: slack_token)
    account
  end
end
