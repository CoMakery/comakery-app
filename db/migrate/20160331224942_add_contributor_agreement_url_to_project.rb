class AddContributorAgreementUrlToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :contributor_agreement_url, :text
  end
end
