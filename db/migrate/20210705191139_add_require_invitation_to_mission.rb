class AddRequireInvitationToMission < ActiveRecord::Migration[6.0]
  def change
    add_column :missions, :require_invitation, :bool, default: true, null: false
  end
end
