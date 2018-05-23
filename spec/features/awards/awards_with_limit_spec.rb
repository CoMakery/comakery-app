require 'rails_helper'

describe 'awarding up to limit of maximum awardable tokens for a project' do
  let!(:team) { create(:team) }
  let!(:current_auth) { create(:sb_authentication) }
  let!(:awardee_auth) { create(:sb_authentication) }
  let!(:project) { create(:sb_project, account: current_auth.account, maximum_tokens: 3, maximum_royalties_per_month: 2) }
  let!(:project1) { create(:sb_project, account: current_auth.account, maximum_tokens: 1, maximum_royalties_per_month: 1) }
  let!(:award_type) { create(:award_type, project: project, amount: 1) }
  let!(:channel) { create(:channel, team: team, project: project, name: 'channel') }
  let!(:channel1) { create(:channel, team: team, project: project1, name: 'channel1') }
  let!(:award_type1) { create(:award_type, project: project1, amount: 1) }

  before do
    team.build_authentication_team current_auth
    team.build_authentication_team awardee_auth

    login(current_auth.account)
    stub_slack_user_list([slack_user_from_auth(awardee_auth)])
    allow_any_instance_of(Account).to receive(:send_award_notifications)
  end

  it 'limit to send award by month' do
    visit project_path(project)

    send_award

    expect(page).to have_content "Successfully sent award to #{Award.last.decorate.recipient_display_name}"

    send_award

    expect(page).to have_content "Successfully sent award to #{Award.last.decorate.recipient_display_name}"

    send_award
    expect(page).to have_content "Sorry, you can't send more awards this month than the project's maximum number of allowable tokens per month"
  end

  it 'limit send award with project maximum token' do
    visit project_path(project1)

    send_award(channel1)
    expect(page).to have_content "Successfully sent award to #{Award.last.decorate.recipient_display_name}"

    send_award(channel1)
    expect(page).to have_content "Sorry, you can't send more awards than the project's maximum number of allowable tokens"
  end

  def send_award(ch = nil)
    ch ||= channel
    select "[slack] #{team.name} ##{ch.name}", from: 'Communication Channel'
    fill_in 'Email Address', with: awardee_auth.uid
    click_on 'Send Award'
  end
end
