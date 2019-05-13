class AllowNullForMaximumTokensInProjects < ActiveRecord::Migration[5.1]
  def change
  	change_column_null :projects, :maximum_tokens, true
  end
end
