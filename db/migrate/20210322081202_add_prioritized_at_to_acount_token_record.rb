class AddPrioritizedAtToAcountTokenRecord < ActiveRecord::Migration[6.0]
  def change
    add_column :account_token_records, :prioritized_at, :datetime
  end
end
