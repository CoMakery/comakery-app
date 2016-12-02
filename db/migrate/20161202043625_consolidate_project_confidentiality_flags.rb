class ConsolidateProjectConfidentialityFlags < ActiveRecord::Migration
  def change
    remove_column :projects, :business_confidentiality, :boolean
    rename_column :projects, :project_confidentiality, :require_confidentiality
  end
end
