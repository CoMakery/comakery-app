class Authentication < ActiveRecord::Base
  belongs_to :account

  def self.find_or_create_from_auth_hash(auth_hash)
    email_address = auth_hash.try(:dig, :extra, :user_info, :user, :profile, :email)
    return unless auth_hash && auth_hash[:provider] && auth_hash[:uid] && email_address

    account = Account.find_or_create_by!(email: email_address)
    Authentication.find_or_create_by!(provider: auth_hash[:provider], uid: auth_hash[:uid], account_id: account.id)
    account
  end
end
