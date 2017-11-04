class AddCommunityAwardableToAwardType < ActiveRecord::Migration[4.2]
  def change
    add_column :award_types, :community_awardable, :boolean, default: false, null: false
  end
end
