require 'rails_helper'

describe 'viewing projects, creating and editing', :js do
  let!(:team) { create :team }
  let!(:token) { create :token }
  let!(:mission) { create :mission, token: token }
  let!(:project) { create(:project, title: 'Cats with Lazers Project', description: 'cats with lazers', account: account, public: false, mission: mission) }
  let!(:public_project) { create(:project, title: 'Public Project', description: 'dogs with donuts', account: account, visibility: 'public_listed', mission: mission) }
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

    fill_in 'Description', with: 'This is a project description which is very informative'
    fill_in "Project Owner's Legal Name", with: 'Mindful Inc'
    fill_in 'Video', with: 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0'

    attach_file 'Project Image', Rails.root.join('spec', 'fixtures', 'helmet_cat.png')

    expect(find_field('project_maximum_tokens')['value']).to eq('1000000')
    fill_in 'project_maximum_tokens', with: '20000000'

    award_type_inputs = get_award_type_rows
    award_type_inputs[0].all('input')[0].set 'This is a small award type'
    award_type_inputs[0].all('input')[1].set '1000'
    award_type_inputs[0].all('textarea')[0].set 'Say hi to earn this'
    award_type_inputs[1].all('input')[0].set 'This is a medium award type'
    award_type_inputs[1].all('input')[1].set '2000'
    award_type_inputs[1].all("input[name*='[community_awardable]']")[0].set(true)
    award_type_inputs[2].all('input')[0].set 'This is a large award type'
    award_type_inputs[2].all('input')[1].set '3000'
    award_type_inputs.last(award_type_inputs.size - 3). each do |input|
      input.all('a[data-mark-and-hide]')[0].click
    end

    click_link '+ add award type'

    award_type_inputs = get_award_type_rows
    expect(award_type_inputs.size).to eq(4)

    award_type_inputs[3].find("input[name*='[name]']").set 'This is a super big award type'
    award_type_inputs[3].find("input[name*='[amount]']").set '5000'

    click_link '+ add award type'

    award_type_inputs = get_award_type_rows
    expect(award_type_inputs.size).to eq(5)

    click_remove(award_type_inputs.last)

    award_type_inputs = get_award_type_rows
    expect(award_type_inputs.size).to eq(4)
    fill_in 'Title', with: 'This is a project'
    select mission.id, from: 'project[mission_id]'

    click_on 'Save', class: 'last_submit'

    expect(page).to have_content 'This is a project'
    expect(page).to have_content 'This is a project description'

    expect(page).not_to have_link 'Project Tasks'

    expect(Project.last.award_types.count).to eq(4)

    click_on 'Edit This Project'

    expect(page.find('.project-image')[:src]).to match(/helmet_cat.png/)

    fill_in 'Title', with: 'This is an edited project'
    fill_in 'Description', with: 'This is an edited project description which is very informative'
    fill_in 'Project Tracker', with: 'http://github.com/here/is/my/tracker'
    fill_in 'Video', with: 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0'

    # youtube player throws js errors, ignore them:
    ignore_js_errors { click_on 'Save', class: 'last_submit' }
    ignore_js_errors { expect(page).to have_content 'Project updated' }

    expect(EthereumTokenContractJob.jobs.length).to eq(0)
    expect(EthereumTokenIssueJob.jobs.length).to eq(0)

    expect(page).to have_content 'This is an edited project'

    expect(page).to have_link 'Project Tasks'

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

    expect(page).not_to have_content 'Edit'
  end
end
