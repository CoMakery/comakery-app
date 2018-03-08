class RefactorProjects < ActiveRecord::Migration[5.1]
  def change
    remove_column :projects, :slack_team_id, :string
    remove_column :projects, :slack_team_name, :string
    remove_column :projects, :slack_team_domain, :string
    remove_column :projects, :slack_team_image_34_url, :string
    remove_column :projects, :slack_team_image_132_url, :string
    rename_column :projects, :account_id, :integer
    rename_column :accounts, :image_content_zise, :image_content_size
    add_column :projects, :image_filename, :string
    add_column :projects, :image_content_size, :string
    add_column :projects, :image_content_type, :string
  end
end
