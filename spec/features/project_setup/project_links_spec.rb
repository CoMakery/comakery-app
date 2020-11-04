require 'rails_helper'

describe 'projects links spec', :js do
  let!(:team) { create :team }
  let!(:project) { create(:project, title: 'Cats with Lazers Project', description: 'cats with lazers', account: account, public: false) }
  let!(:public_project) { create(:project, title: 'Public Project', description: 'dogs with donuts', account: account, visibility: 'public_listed') }
  let!(:public_project_award_type) { create(:award_type, project: public_project) }
  let!(:public_project_award) { create(:award, award_type: public_project_award_type, created_at: Date.new(2016, 1, 9)) }
  let!(:account) { create(:account, first_name: 'Glenn', last_name: 'Spanky', email: 'gleenn@example.com') }
  let!(:authentication) { create(:authentication, account: account) }
  let!(:same_team_account) { create(:account) }
  let!(:same_team_account_authentication) { create(:authentication, account: same_team_account) }
  let!(:other_team_account) { create(:account).tap { |a| create(:authentication, account_id: a.id) } }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team same_team_account_authentication
    travel_to Date.new(2016, 1, 10)
    stub_slack_user_list
    stub_slack_channel_list
  end

  it 'does the happy path' do
    login(account)

    visit projects_path
    expect(page).to have_content 'New Project' # wait for new project button to appear before pressing it to avoid random test failure
    click_link 'New Project'

    expect(page).to have_content 'Permissions & Visibility'
    fill_in 'project[title]', with: 'This is a project'
    fill_in 'project[description]', with: 'This is a project description which is very informative'
    fill_in 'project[maximum_tokens]', with: '1000'
    find_button('create', class: 'button__border').click
    expect(page).to have_content 'Project Created'

    # BEFORE LINKS CREATED
    visit project_path(project)
    expect(page).not_to have_content 'GitHub'
    expect(page).not_to have_content 'Documentation'
    expect(page).not_to have_content 'Getting Started'
    expect(page).not_to have_content 'Governance'
    expect(page).not_to have_content 'Funding'
    expect(page).not_to have_content 'Video Conference'

    # CREATE LINKS
    click_link 'settings'
    expect(page).to have_content 'Permissions & Visibility'
    fill_in 'project[title]', with: 'This is an edited project'

    find_button('save', class: 'button__border').click
    expect(page).to have_content 'Project Updated'
    fill_in 'project[github_url]', with: 'https://www.github.com/comakery'
    fill_in 'project[documentation_url]', with: 'https://www.wiki.com/example'
    fill_in 'project[getting_started_url]', with: 'https://drive.google.com/example'
    fill_in 'project[governance_url]', with: 'https://loomio.org/example'
    fill_in 'project[funding_url]', with: 'https://opencollective.org/example'
    fill_in 'project[video_conference_url]', with: 'https://loomio.org/example'
    find_button('save', class: 'button__border').click
    expect(page).to have_content 'Project Updated'

    # AFTER LINKS CREATED - PROJECT INDEX SHOULD DISPLAY THEM
    visit project_path(project)
    expect(page).to have_content 'This is an edited project'
    expect(page).to have_link 'GitHub', href: 'https://www.github.com/comakery'
    expect(page).to have_link 'Documentation', href: 'https://www.wiki.com/example'
    expect(page).to have_link 'Getting Started', href: 'https://drive.google.com/example'
    expect(page).to have_link 'Governance', href: 'https://loomio.org/example'
    expect(page).to have_link 'Funding', href: 'https://opencollective.org/example'
    expect(page).to have_link 'Video Conference', href: 'https://loomio.org/example'

    # THE PROJECT SETTINGS SHOULD SHOW THE STORED DB VALUES
    click_link 'settings'
    expect(page).to have_field 'project[github_url]', with: 'https://www.github.com/comakery'
    expect(page).to have_field 'project[documentation_url]', with: 'https://www.wiki.com/example'
    expect(page).to have_field 'project[getting_started_url]', with: 'https://drive.google.com/example'
    expect(page).to have_field 'project[governance_url]', with: 'https://loomio.org/example'
    expect(page).to have_field 'project[funding_url]', with: 'https://opencollective.org/example'
    expect(page).to have_field 'project[video_conference_url]', with: 'https://loomio.org/example'
  end
end
