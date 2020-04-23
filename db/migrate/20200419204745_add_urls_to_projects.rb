class AddUrlsToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :github_url, :text
    add_column :projects, :documentation_url, :text
    add_column :projects, :getting_started_url, :text
    add_column :projects, :governance_url, :text
    add_column :projects, :funding_url, :text
    add_column :projects, :video_conference_url, :text
  end
end
