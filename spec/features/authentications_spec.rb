require 'rails_helper'

describe "viewing user auth" do
  let!(:project) { create(:sb_project) }
  let!(:auth) { create(:sb_authentication) }
  let!(:issuer) { create(:sb_authentication, slack_user_name: "John Collins") }
  let!(:award_type) { create(:award_type, project: project, amount: 1337) }
  let!(:award1) { create(:award, award_type: award_type, authentication: auth, issuer: issuer.account) }
  let!(:award2) { create(:award, award_type: award_type, authentication: auth, issuer: issuer.account) }

  before { travel_to Date.new(2016, 3, 25) }

  specify do
    visit root_path

    expect(page).not_to have_content "Settings"

    login(auth.account)

    visit root_path

    click_link "Settings"

    expect(page).to have_content "Swarmbot"
    expect(page).to have_content "1,337"
    expect(page).to have_content "Mar 25, 2016"
    expect(page).to have_content "Contribution"
    expect(page).to have_content "Great work"
    expect(page).to have_content "John Doe"
  end
end