class AddBankAccountFieldsToAuthentication < ActiveRecord::Migration
  def change
    add_column :authentications, :bank_account_account_holder_type, :text
    add_column :authentications, :bank_account_bank_name, :text
    add_column :authentications, :bank_account_country, :text
    add_column :authentications, :bank_account_currency, :text
    add_column :authentications, :bank_account_id, :text
    add_column :authentications, :bank_account_last4, :text
    add_column :authentications, :bank_account_name, :text
    add_column :authentications, :bank_account_object, :text
    add_column :authentications, :bank_account_routing_number, :text
    add_column :authentications, :bank_account_status, :text

    add_column :authentications, :stripe_token_client_ip, :text
    add_column :authentications, :stripe_token_created, :datetime
    add_column :authentications, :stripe_token_id, :text
    add_column :authentications, :stripe_token_type, :text
    add_column :authentications, :stripe_token_livemode, :boolean
  end
end