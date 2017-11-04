class ConsolidateProjectConfidentialityFlags < ActiveRecord::Migration[4.2]
  def change
    remove_column :projects, :business_confidentiality, :boolean
    rename_column :projects, :project_confidentiality, :require_confidentiality
  end
end
