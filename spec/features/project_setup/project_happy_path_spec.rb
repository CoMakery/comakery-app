require 'rails_helper'

describe 'viewing projects, creating and editing', :js do
  let!(:team) { create :team }
  let!(:project) { create(:project, title: 'Cats with Lazers Project', description: 'cats with lazers', account: account, public: false) }
  let!(:public_project) { create(:project, title: 'Public Project', description: 'dogs with donuts', account: account, visibility: 'public_listed') }
  let!(:public_project_award_type) { create(:award_type, project: public_project) }
  let!(:public_project_award) { create(:award, award_type: public_project_award_type, created_at: Date.new(2016, 1, 9)) }
  let!(:account) { create(:account, first_name: 'Glenn', last_name: 'Spanky', email: 'gleenn@example.com') }
  let!(:authentication) { create(:authentication, account: account) }
  let!(:same_team_account) { create(:account, ethereum_wallet: "0x#{'1' * 40}") }
  let!(:same_team_account_authentication) { create(:authentication, account: same_team_account) }
  let!(:other_team_account) { create(:account).tap { |a| create(:authentication, account_id: a.id) } }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team same_team_account_authentication
    Rails.application.config.allow_ethereum = 'citizencodedomain'
    travel_to Date.new(2016, 1, 10)
    stub_slack_user_list
    stub_slack_channel_list
  end

  it 'does the happy path' do
    login(account)
    visit projects_path
    expect(page).to have_content 'Cats with Lazers Project'
    within "#project-#{project.to_param}" do
      click_link project.title
    end

    visit projects_path
    click_link 'New Project'
    expect(page).to have_content 'New Project'
    fill_in 'project[title]', with: 'This is a project'
    fill_in 'project[description]', with: 'This is a project description which is very informative'
    fill_in 'project[maximum_tokens]', with: '1000'
    fill_in 'project[video_url]', with: 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0'
    fill_in 'project[legal_project_owner]', with: 'Mindful Inc'
    attach_file 'project[square_image]', Rails.root.join('spec', 'fixtures', '1200.png')
    attach_file 'project[panoramic_image]', Rails.root.join('spec', 'fixtures', '1500.png')
    find_button('create').click
    expect(page).to have_content 'PROJECT CREATED'

    fill_in 'project[title]', with: 'This is an edited project'
    fill_in 'project[description]', with: 'This is an edited project description which is very informative'
    find_button('save').click
    expect(page).to have_content 'PROJECT UPDATED'
    visit('/projects')
    expect(page).to have_content 'This is an edited project'

    Project.last.channels.create(team: team, channel_id: 'channel id')
    expect(Project.last.channels.count).to eq 1
    login(same_team_account)
    visit('/projects')
    expect(page).to have_content 'This is an edited project'

    login(other_team_account)
    visit('/projects')
    expect(page).not_to have_content 'This is an edited project'
    expect(page).to have_content 'Public Project'
    click_link 'Public Project'
    expect(page).not_to have_content 'EDIT THIS PROJECT'
  end
end
