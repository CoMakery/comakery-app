class DropBetaSignupsTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :beta_signups do |t|
      t.string :email_address
      t.string :name
      t.string :slack_instance
      t.boolean :opt_in
      t.jsonb :oauth_response
    end
  end
end
