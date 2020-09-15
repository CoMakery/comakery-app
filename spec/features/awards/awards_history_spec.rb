require 'rails_helper'

describe 'viewing projects, creating and editing', :js do
  context 'when not owner' do
    let!(:team) { create :team }
    let!(:owner) { create(:account) }
    let!(:owner_auth) { create(:authentication, account: owner) }
    let!(:other_account) { create(:account) }
    let!(:other_account_auth) { create(:authentication, account: other_account) }
    let!(:project) { create(:project, visibility: 'public_listed', account: owner) }
    let!(:project2) { create(:project, visibility: 'public_listed', account: owner) }
    let!(:award_type) { create(:award_type, project: project, community_awardable: false) }
    let!(:channel) { create(:channel, project: project, team: team) }
    let!(:community_award_type) { create(:award_type, project: project, community_awardable: true) }
    let!(:community_award_type2) { create(:award_type, project: project2, community_awardable: true) }
    let!(:award) { create(:award, award_type: award_type, account: other_account, channel: channel, amount: 1000) }
    let!(:community_award) { create(:award, award_type: community_award_type, account: owner, amount: 10) }

    before do
      team.build_authentication_team owner_auth
      team.build_authentication_team other_account_auth
      stub_slack_user_list
      stub_slack_channel_list
    end

    context 'when logged out' do
      context 'viewing awards' do
        it 'lets people view awards' do
          visit awards_project_path(project)

          expect(page).to have_css '#contributions-chart'
          expect(page).to have_css 'table.award-rows'
        end

        it 'show link to ethereum transaction' do
          stub_token_symbol
          project.token.update ethereum_enabled: true, contract_address: '0x583cbbb8a8443b38abcc0c956bece47340ea1367', _token_type: 'erc20', _blockchain: :ethereum_ropsten
          award.update ethereum_transaction_address: '0xb808727d7968303cdd6486d5f0bdf7c0f690f59c1311458d63bc6a35adcacedb'
          login(owner)
          project.token.reload
          visit awards_project_path(project)

          expect(page).to have_content 'Blockchain Transaction'
        end

        it 'paginates when there are lots of awards' do
          55.times do
            create(:award, award_type: community_award_type2)
          end

          visit awards_project_path(project2)

          expect(page.all('table.award-rows tr.award-row').size).to eq(50)
          expect(page).to have_content '1 2 › »'

          within(page.all('.pagination').first) do
            click_link '»'
          end

          wait_for_turbolinks

          expect(page.all('table.award-rows tr.award-row').size).to eq(5)
          expect(page).to have_content '« ‹ 1 2'
        end
      end
    end
  end
end
