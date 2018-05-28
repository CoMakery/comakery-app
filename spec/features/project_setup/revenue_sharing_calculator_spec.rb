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

    travel_to(DateTime.parse('Mon, 29 Feb 2016 00:00:00 +0000')) # so we can check for fixed date of award

    allow_any_instance_of(Account).to receive(:send_award_notifications)
    stub_slack_user_list([{ "id": 'U99M9QYFQ', "team_id": 'team id', "name": 'bobjohnson', "profile": { "email": 'bobjohnson@example.com' } }])
    stub_request(:post, 'https://slack.com/api/users.info').to_return(body: {
      ok: true,
      "user": {
        "id": 'U99M9QYFQ',
        "team_id": 'team id',
        "name": 'bobjohnson',
        "profile": {
          email: 'bobjohnson@example.com'
        }
      }
    }.to_json)

    login(account)
  end

  after do
    travel_back
  end

  describe 'displays alternate text for project tokens' do
    it 'when selecting payment type' do
      visit edit_project_path(project)
      expect(page).not_to have_css('.revenue-sharing-terms')

      expect(page).to have_css('.project-token-terms')
      within('.project-token-terms') { expect(page).to have_content('About Project Tokens') }
    end

    it 'when editing an existing project' do
      project.update(payment_type: :project_token)
      visit edit_project_path(project)
      expect(page).not_to have_css('.revenue-sharing-terms')
      expect(page).to have_css('.project-token-terms')
    end
  end
end
