class AddSlackTeamDomainToAuthenticationsAndProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :authentications, :slack_team_domain, :string
    add_column :projects, :slack_team_domain, :string
  end
end
