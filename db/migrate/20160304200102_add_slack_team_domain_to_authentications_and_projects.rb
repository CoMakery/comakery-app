class AddSlackTeamDomainToAuthenticationsAndProjects < ActiveRecord::Migration
  def change
    add_column :authentications, :slack_team_domain, :string
    add_column :projects, :slack_team_domain, :string
  end
end
