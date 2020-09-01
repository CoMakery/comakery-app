#!/usr/bin/env ruby

require_relative '../../config/environment'
require_relative '../../spec/support/mom'

DEMOS = [
  {
    fixture: 'rails',
    project_model: {
      title: 'Ruby on Rails',
      description: %{Rails is a web-application framework that includes everything needed to create database-backed web applications according to the Model-View-Controller (MVC) pattern.\n\nIn addition to MVC, Rails emphasizes the use of other well-known software engineering patterns and paradigms, including convention over configuration, don't repeat yourself, and the active record pattern.},
      tracker: 'https://github.com/rails/rails/issues'
    },
    owner_name: 'David Heinemeier Hansson',
    team_name: 'Ruby on Rails',
    team_image: 'http://www.bytebob.com/images/ruby.png',
    project_image: 'rails.jpg'
  },
  {
    fixture: 'go-ipfs',
    project_model: {
      title: 'IPFS Core',
      description: %{The InterPlanetary File System (IPFS) is a new hypermedia distribution protocol, addressed by content and identities. IPFS enables the creation of completely distributed applications. It aims to make the web faster, safer, and more open.  IPFS is an open source project developed by the IPFS Community and many contributors from the open source community.},
      tracker: 'https://waffle.io/ipfs/ipfs'
    },
    owner_name: 'Juan Benet',
    team_name: 'Protocol Labs',
    team_image: 'https://upload.wikimedia.org/wikipedia/en/1/18/Ipfs-logo-1024-ice-text.png',
    project_image: 'go-ipfs.png'
  },
  {
    fixture: 'swarmbot',
    project_model: {
      title: 'Swarmbot',
      description: %(An open source solution to infect Slack messaging networks with community crypto tokens and space kitty kuteness. Swarmbot helps you make contributions and receive project tokens. This helps you track your contributions to projects and receive profit distributions!),
      tracker: 'https://github.com/CoMakery/swarmbot/issues'
    },
    owner_name: 'CoMakery',
    team_name: 'CoMakery',
    team_image: 'https://s3.amazonaws.com/comakery/spacekitty.jpg',
    project_image: 'swarmbot.jpg'
  }
].freeze

def main
  DEMOS.each { |demo| make demo }
end

def make(fixture:, project_model:, owner_name:, team_name:, team_image:, project_image:)
  owner = auth owner_name, team_name, team_image
  project = project_factory owner.account, project_model.reverse_merge(
    public: true,
    slack_team_name: team_name,
    slack_team_id: team_name,
    slack_team_image_34_url: team_image,
    slack_team_image_132_url: team_image,
    image: File.new(get_fixture(project_image)),
    maximum_tokens: 10_000_000
  )
  award_type = create :award_type, name: 'Commit', project: project
  fixture_path = get_fixture "#{fixture}.json"
  contributions = JSON.load IO.read fixture_path
  contributions.each do |date, data|
    data.each do |name, amount|
      amount.times do
        recipient_auth = auth(name, team_name, team_image)
        award = create :award, recipient_auth, owner.account, # rubocop:todo Lint/UselessAssignment
                       award_type: award_type,
                       amount: 100,
                       description: 'Git commit',
                       created_at: date,
                       updated_at: date
      end
    end
  end
end

def auth(name, team_name, team_image)
  auth = Authentication.find_by slack_first_name: name, slack_team_id: team_name
  attrs = {
    slack_first_name: name,
    slack_last_name: nil,
    slack_user_name: name.gsub(/[^[[:alpha:]]]+/, '-').downcase,
    slack_team_name: team_name,
    slack_team_id: team_name,
    slack_team_image_34_url: team_image,
    slack_team_image_132_url: team_image
  }

  if auth
    auth.update_attributes! attrs
  else
    auth = create :authentication, attrs
  end

  auth.account ||= create :account
  auth.save!
  auth
end

# find or create project with the given title
def project_factory(owner, params)
  project = Project.find_by(
    title: params[:title],
    account_id: owner.id,
    slack_team_name: params[:slack_team_name]
  )
  if project
    project.update_attributes!(**params)
    project.award_types.each { |award_type| award_type.awards.destroy_all }
    project.award_types.destroy_all
  else
    project = create :project, owner, **params
  end
  project
end

def get_fixture(file)
  File.expand_path "../fixtures/#{file}", __FILE__
end

main
