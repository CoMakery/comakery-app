require 'rails_helper'

describe 'landing page', :js do
  let!(:team) { create :team }
  let!(:account) { create(:account, nickname: 'gleenn', email: 'gleenn@example.com') }
  let!(:account1) { create(:account, nickname: 'Rick', email: 'rick@example.com') }
  let!(:authentication) { create :authentication, account: account }
  let!(:authentication1) { create :authentication, account: account1 }
  let!(:swarmbot_account) { create(:account, email: 'swarm@example.com') }
  let(:swarmbot_authentication) { create :authentication, account: swarmbot_account }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team authentication1
  end

  it 'when logged in shows some projects and the new button' do
    login(account)
    project = create(:project, title: 'member Private Project', visibility: 'member', account: account1)
    project.channels.create(team: team, channel_id: 'channel')
    7.times { |i| create(:project, account: swarmbot_account, title: "Public Project #{i}", visibility: 'public_listed') }
    7.times { |i| create(:project, title: "other Private Project #{i}", visibility: 'member') }
    7.times { |i| create(:project, account, title: "Private Project #{i}", visibility: 'member') }
    7.times { |i| create(:project, account, title: "Archived Project #{i}", visibility: 'archived') }

    visit my_project_path

    expect(page).to have_content 'gleenn'

    expect(page).to have_content 'mine'
    expect(page).to have_content 'mine'
    expect(page).to have_content 'New Project'

    expect(page.all('.project').size).to eq(13)

    click_link 'Browse All'

    within('h2') { expect(page.text).to eq('Projects') }
    expect(page).to have_content 'New Project'

    expect(page.all('.project').size).to eq(9)
  end

  it 'when logged out shows featured projects first' do
    (1..3).each { |i| create(:project, account: swarmbot_account, title: "Featured Project #{i}", visibility: 'public_listed', featured: i) }
    (1..7).each { |i| create(:project, account: swarmbot_account, title: "Public Project #{i}", visibility: 'public_listed') }

    (1..7).each { |i| create(:project, account, title: "Private Project #{i}", public: false) }

    visit my_project_path

    expect(page.all('.project').size).to eq(6)
    within('.main') do
      expect(page).to have_text 'Featured Project 1'
      expect(page).to have_text 'Featured Project 2'
      expect(page).to have_text 'Featured Project 3'
      expect(page).to have_text 'Public Project 5'
      expect(page).to have_text 'Public Project 6'
      expect(page).to have_text 'Public Project 7'

      expect(page).not_to have_text 'Public Project 4' # not featured and less active doesn't appear
    end
    click_link 'Browse All'

    within('h2') { expect(page.text).to eq('Projects') }

    expect(page.all('.project').size).to eq(9)
    expect(page).to have_content 'Featured Project'
    expect(page).to have_content 'Public Project'
    expect(page).not_to have_content 'Private Project'
  end
end
