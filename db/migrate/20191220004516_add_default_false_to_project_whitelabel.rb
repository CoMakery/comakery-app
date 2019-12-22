class AddDefaultFalseToProjectWhitelabel < ActiveRecord::Migration[6.0]
  def up
    change_column_default :projects, :whitelabel, false
    change_column_null    :projects, :whitelabel, false, false
  
    change_column_default :missions, :whitelabel, false
    change_column_null    :missions, :whitelabel, false, false
  end

  def down
    change_column :projects, :whitelabel, :boolean, :default => nil, :null => true
    change_column :missions, :whitelabel, :boolean, :default => nil, :null => true
  end
end
