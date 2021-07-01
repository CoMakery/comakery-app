class ChangeAccountIdInProjectRole < ActiveRecord::Migration[6.0]
  def change
    change_column_null :project_roles, :account_id, true
  end
end
