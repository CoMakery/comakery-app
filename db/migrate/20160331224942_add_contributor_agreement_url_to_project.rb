class AddContributorAgreementUrlToProject < ActiveRecord::Migration
  def change
    add_column :projects, :contributor_agreement_url, :text
  end
end
