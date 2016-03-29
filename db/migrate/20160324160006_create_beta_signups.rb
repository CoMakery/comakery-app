class CreateBetaSignups < ActiveRecord::Migration
  def change
    create_table :beta_signups do |t|
      t.string :email_address, null: false
      t.string :name
      t.string :slack_instance
      t.boolean :opt_in, null: false, default: false
      t.jsonb :oauth_response
    end
  end
end
