class AddDiscordInviteToChannels < ActiveRecord::Migration[5.1]
  def change
    add_column :channels, :discord_invite_code, :string
    add_column :channels, :discord_invite_created_at, :datetime
  end
end
