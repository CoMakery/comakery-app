class AddContractFieldsToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :exclusive_contributions, :boolean
    add_column :projects, :legal_project_owner, :string
    add_column :projects, :minimum_payment, :integer
    add_column :projects, :minimum_revenue, :integer
    add_column :projects, :business_confidentiality, :boolean
    add_column :projects, :project_confidentiality, :boolean
    add_column :projects, :royalty_percentage, :integer
    add_column :projects, :maximum_royalties_per_quarter, :integer
  end
end
