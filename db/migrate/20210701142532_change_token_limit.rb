class ChangeTokenLimit < ActiveRecord::Migration[6.0]
  def change
    change_column :invites, :token, :string, limit: Invite::TOKEN_LENGTH
  end
end
