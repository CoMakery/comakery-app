class AddVideoUrlToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :video_url, :text
  end
end
