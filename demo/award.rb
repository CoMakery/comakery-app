#!/usr/bin/env ruby

require_relative '../config/environment'
require_relative '../spec/support/mom'

DEMOS = [
  {
    fixture: 'rails',
    project_model: {
      title: 'Ruby on Rails',
      description: %{Rails is a web-application framework that includes everything needed to create database-backed web applications according to the Model-View-Controller (MVC) pattern.}
    },
    owner_name: "David Heinemeier Hansson",
    team_name: 'Ruby on Rails',
    team_image: 'http://rubyonrails.org/images/rails-logo.svg'
  },
  {
    fixture: 'go-ipfs',
    project_model: {
      title: 'IPFS Core',
      description: %{The InterPlanetary File System (IPFS) is a new hypermedia distribution protocol, addressed by content and identities. IPFS enables the creation of completely distributed applications. It aims to make the web faster, safer, and more open.  IPFS is an open source project developed by the IPFS Community and many contributors from the open source community.}
    },
    owner_name: "Juan Benet",
    team_name: 'Protocol Labs',
    team_image: 'https://ipfs.io/styles/img/ipfs-logo-white.png'
  }
]

def main
  DEMOS.each { |demo| make demo }
end

def make fixture:, project_model:, owner_name:, team_name:, team_image:
  owner = user owner_name, team_name
  project = project_factory owner, project_model.reverse_merge(
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
        award = create :award, user(name, team_name), owner,
          award_type: award_type,
          description: 'Git commit',
          created_at: date,
          updated_at: date
      end
    end
  end
end

def user name, team_name
  auth = Authentication.find_by slack_first_name: name
  auth ||= create :authentication,
    slack_first_name: name,
    slack_last_name: nil,
    slack_user_name: name.gsub(/[^[[:alpha:]]]+/, '-').downcase,
    slack_team_name: team_name,
    slack_team_id: team_name

  auth.account ||= create :account
  auth.save!
  auth.account
end

# find or create project with the given title
def project_factory owner, params
  project = Project.find_by title: params[:title]
  project ||= create :project, owner, **params
  project
end

main
