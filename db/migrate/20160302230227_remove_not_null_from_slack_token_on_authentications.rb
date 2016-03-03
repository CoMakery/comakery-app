class RemoveNotNullFromSlackTokenOnAuthentications < ActiveRecord::Migration
  def up
    change_column :authentications, :slack_token, :string, null: true
  end

  def down
    change_column :authentications, :slack_token, :string, null: false, default: ""
  end
end
