require 'rails_helper'

describe "payments" do
  let!(:project) { create(:project, title: "Project that needs awards", owner_account: owner_account, slack_team_id: "team id", ethereum_enabled: true, ethereum_contract_address: '0x' + '2' * 40) }
  let!(:small_award_type) { create(:award_type, project: project, name: "Small", amount: 10) }
  let!(:owner_account) { create(:account, email: "hubert@example.com") }
  let!(:other_account) { create(:account, email: "sherman@example.com") }

  let!(:owner_authentication) { create(:authentication, slack_user_name: 'hubert', slack_first_name: 'Hubert', slack_last_name: 'Sherbert', slack_user_id: 'hubert id', account: owner_account, slack_team_id: "team id", slack_team_image_34_url: "http://avatar.com/owner_team_avatar.jpg") }
  let!(:sherman_authentication) { create(:authentication, slack_user_name: 'sherman', slack_user_id: 'sherman id', slack_first_name: "Sherman", slack_last_name: "Yessir", account: other_account, slack_team_id: "team id", slack_image_32_url: "http://avatar.com/other_account_avatar.jpg") }

  describe "when awards and payments have been issued" do
    before do
      stub_slack_user_list([])
      create(:award, issuer: owner_account, authentication: sherman_authentication, award_type: small_award_type)
      create(:payment, project: project, issuer: owner_account, recipient: sherman_authentication, amount: 3)
    end

    it "populates shows the earned, paid, remaining" do
      login(owner_account)

      visit project_contributors_path(project)
      within(".award-row") do
        within('.contributor') do
          expect(page).to have_content "Sherman Yessir"
        end
        within('.earned') { expect(page).to have_content '$10' }
        within('.paid') { expect(page).to have_content '$3' }
        within('.remaining') { expect(page).to have_content '$7' }
      end

    end
  end

end
