class LinkWalletToAccountTokenRecord < ActiveRecord::Migration[6.0]
  def change
    add_reference :account_token_records, :wallet, foreign_key: true, index: true
  end
end
