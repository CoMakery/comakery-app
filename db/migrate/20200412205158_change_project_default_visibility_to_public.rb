class ChangeProjectDefaultVisibilityToPublic < ActiveRecord::Migration[6.0]
  def up
    change_column_default :projects, :visibility, 1
  end

  def down
    change_column_default :projects, :visibility, 0
  end
end
