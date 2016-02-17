class Authentication < ActiveRecord::Base
  belongs_to :account

  def self.find_or_create_from_auth_hash(auth_hash)
    auth_hash = auth_hash.to_h
    email_address = auth_hash.dig('extra', 'user_info', 'user', 'profile', 'email')
    return nil unless auth_hash && auth_hash['provider'] && auth_hash['uid'] && email_address

    account = Account.find_or_create_by!(email: email_address)
    Authentication.find_or_create_by!(provider: auth_hash['provider'], uid: auth_hash['uid'], account_id: account.id)
    account
  end
end
