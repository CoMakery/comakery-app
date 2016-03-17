class AddCommunityAwardableToAwardType < ActiveRecord::Migration
  def change
    add_column :award_types, :community_awardable, :boolean, default: false, null: false
  end
end
