require 'rails_helper'

describe 'awarding up to limit of maximum awardable tokens for a project' do
  let!(:current_auth) { create(:sb_authentication) }
  let!(:awardee_auth) { create(:sb_authentication) }
  let!(:project) { create(:sb_project, owner_account: current_auth.account, maximum_tokens: 3, maximum_royalties_per_month: 2) }
  let!(:project1) { create(:sb_project, owner_account: current_auth.account, maximum_tokens: 1, maximum_royalties_per_month: 1) }
  let!(:award_type) { create(:award_type, project: project, amount: 1) }
  let!(:award_type1) { create(:award_type, project: project1, amount: 1) }

  before do
    login(current_auth.account)
    stub_slack_user_list([slack_user_from_auth(awardee_auth)])
    allow_any_instance_of(Account).to receive(:send_award_notifications)
  end

  it 'limit to send award by month' do
    visit project_path(project)

    send_award

    expect(page).to have_content 'Successfully sent award to John Doe'

    send_award

    expect(page).to have_content 'Successfully sent award to John Doe'

    expect(page).to have_content "You can't send more awards this month than the project's maximum number of allowable tokens per month"
  end

  it 'limit send award with project maximum token' do
    visit project_path(project1)

    send_award

    expect(page).to have_content 'Successfully sent award to John Doe'
    expect(page).to have_content "You can't send more awards than the project's maximum number of allowable tokens"
  end

  def send_award
    select 'John Doe - @johndoe', from: 'User'
    page.find("input[name='award[award_type_id]']").set(true)
    click_on 'Send Award'
  end
end
