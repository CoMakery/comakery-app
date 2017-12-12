class RemoveNotNullFromSlackTokenOnAuthentications < ActiveRecord::Migration[4.2]
  def up
    change_column :authentications, :slack_token, :string, null: true
  end

  def down
    change_column :authentications, :slack_token, :string, null: false, default: ""
  end
end
