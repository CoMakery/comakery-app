#!/usr/bin/env ruby

require_relative '../config/environment'
require_relative '../spec/support/mom'

DEMOS = [
  {
    fixture: 'rails',
    project_model: {
      title: 'Ruby on Rails',
      description: %{Rails is a web-application framework that includes everything needed to create database-backed web applications according to the Model-View-Controller (MVC) pattern.},
      tracker: 'https://github.com/rails/rails/issues'
    },
    owner_name: "David Heinemeier Hansson",
    team_name: 'Ruby on Rails',
    team_image: 'http://www.bytebob.com/images/ruby.png'
  },
  {
    fixture: 'go-ipfs',
    project_model: {
      title: 'IPFS Core',
      description: %{The InterPlanetary File System (IPFS) is a new hypermedia distribution protocol, addressed by content and identities. IPFS enables the creation of completely distributed applications. It aims to make the web faster, safer, and more open.  IPFS is an open source project developed by the IPFS Community and many contributors from the open source community.},
      tracker: 'https://waffle.io/ipfs/ipfs'
    },
    owner_name: "Juan Benet",
    team_name: 'Protocol Labs',
    team_image: 'https://upload.wikimedia.org/wikipedia/en/1/18/Ipfs-logo-1024-ice-text.png'
  }
]

def main
  DEMOS.each { |demo| make demo }
end

def make fixture:, project_model:, owner_name:, team_name:, team_image:
  owner = auth owner_name, team_name, team_image
  project = project_factory owner.account, project_model.reverse_merge(
    public: true,
    slack_team_name: team_name,
    slack_team_id: team_name,
    slack_team_image_34_url: team_image,
    slack_team_image_132_url: team_image
  )
  award_type = create :award_type, amount: 100, name: 'Commit', project: project
  fixture_path = File.expand_path "../fixtures/#{fixture}.json", __FILE__
  contributions = JSON.load IO.read fixture_path
  contributions.each do |date, data|
    data.each do |name, amount|
      amount.times do
        recipient_auth = auth(name, team_name, team_image)
        award = create :award, recipient_auth, owner.account,
          award_type: award_type,
          description: 'Git commit',
          created_at: date,
          updated_at: date
      end
    end
  end
end

def auth name, team_name, team_image
  auth = Authentication.find_by slack_first_name: name
  auth ||= create :authentication,
    slack_first_name: name,
    slack_last_name: nil,
    slack_user_name: name.gsub(/[^[[:alpha:]]]+/, '-').downcase,
    slack_team_name: team_name,
    slack_team_id: team_name,
    slack_team_image_34_url: team_image,
    slack_team_image_132_url: team_image

  auth.account ||= create :account
  auth.save!
  auth
end

# find or create project with the given title
def project_factory owner, params
  project = Project.find_by title: params[:title]
  if project
    project.update_attributes! **params
  else
    project = create :project, owner, **params
  end
  project
end

main
