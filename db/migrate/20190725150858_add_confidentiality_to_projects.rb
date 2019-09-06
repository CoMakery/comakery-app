class AddConfidentialityToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :confidentiality, :bool, default: true
  end
end
