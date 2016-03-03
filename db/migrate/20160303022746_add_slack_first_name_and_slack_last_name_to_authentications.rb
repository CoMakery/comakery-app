class AddSlackFirstNameAndSlackLastNameToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :slack_first_name, :string
    add_column :authentications, :slack_last_name, :string
  end
end
